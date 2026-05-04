from utils import log
import boto3


def copy_recovery_point(
    source_vault_name,
    destination_vault_arn,
    recovery_point_arn,
    iam_role_arn,
    delete_after_days=30
):
    """
    Copia un recovery point desde un backup vault a otro.

    Args:
        source_vault_name (str): Nombre del vault origen
        destination_vault_arn (str): ARN del vault destino
        recovery_point_arn (str): ARN del recovery point a copiar
        iam_role_arn (str): IAM role con permisos para AWS Backup
        delete_after_days (int): Retención en días en el vault destino
    """
    backup = boto3.client("backup")
    lifecycle = {
        "DeleteAfterDays": delete_after_days
    }

    response = backup.start_copy_job(
        RecoveryPointArn=recovery_point_arn,
        SourceBackupVaultName=source_vault_name,
        DestinationBackupVaultArn=destination_vault_arn,
        IamRoleArn=iam_role_arn,
        Lifecycle=lifecycle
    )

    return response

def replicate_cross_account_backup(backup_id, backup_vault_origin, config):
    """
    Replicates a backup to all configured destinations and regions.
    Args:
        backup_id (List[str]): ID of the backup to replicate.
        backup_vault_origin (str): Name of the source backup vault.
        config: Configuration object with destinations and options.
    Returns:
        None
    """
    log("info", "Starting backup replication", backup_id=backup_id)
    
    for account_id, dest in config.destinations.items():
        log("info", "Processing destination account", account_id=account_id)

        for region_name, region_cfg in dest.regions.items():
            log("info", "Replicating to region", account_id=account_id, region=region_name)
            for recovery_point_arn in backup_id:
                if "awsbackup:copyjob" not in recovery_point_arn:
                    continue
                copy_recovery_point(
                    source_vault_name=backup_vault_origin,  # Assuming source vault name is the same as source region, adjust if needed
                    destination_vault_arn=dest.vault_arn,
                    recovery_point_arn=recovery_point_arn,
                    iam_role_arn=dest.iam_role_arn,
                    delete_after_days=dest.delete_after_days)

    log("info", "Backup replication finished for all destinations", backup_id=backup_id)
