'use strict';

const awsParameterStore = require('..');
const assert = require('assert').strict;

assert.strictEqual(awsParameterStore(), 'Hello from awsParameterStore');
console.info("awsParameterStore tests passed");
