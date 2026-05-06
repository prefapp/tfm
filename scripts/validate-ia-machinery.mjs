import { readFileSync } from 'node:fs';

const requiredFiles = ['CONSTITUTION.md', 'AGENTS.md', 'RULES.md', 'CONTRIBUTING.md'];

function read(path) {
  return readFileSync(path, 'utf8');
}

function assertContains(path, content, expected) {
  if (!content.includes(expected)) {
    throw new Error(`${path} must contain: ${expected}`);
  }
}

for (const file of requiredFiles) {
  read(file);
}

const constitution = read('CONSTITUTION.md');
assertContains('CONSTITUTION.md', constitution, 'CONTRIBUTING.md');
assertContains('CONSTITUTION.md', constitution, 'GitHub Automated Provisioning Systems');
assertContains('CONSTITUTION.md', constitution, 'variable "config"');

const agents = read('AGENTS.md');
assertContains('AGENTS.md', agents, 'CONSTITUTION.md');
assertContains('AGENTS.md', agents, 'CONTRIBUTING.md');
assertContains('AGENTS.md', agents, 'RULES.md');

const rules = read('RULES.md');
assertContains('RULES.md', rules, 'terraform.tfvars.json');
assertContains('RULES.md', rules, '"config"');
assertContains('RULES.md', rules, 'One Firestartr Kubernetes custom resource');
assertContains('RULES.md', rules, 'Import');
assertContains('RULES.md', rules, 'Delete');

console.log('IA machinery validation passed.');
