require('dotenv').config();
const assert = require('assert');
const axios = require('axios').default;
const uriTemplate = require('uri-template');
const { Octokit } = require('@octokit/core');
const octokit = new Octokit({ auth: process.env.GH_TOKEN });
const fs = require('fs');
const path = require('path');
const util = require('util');
const pjson = require('./package.json');
fs.readFile = util.promisify(fs.readFile);

// Read changelog.txt and pull the version and changes from it
async function readChangeLog(filename) {
  let changelogContents = await fs.readFile(filename);
  let out = [];
  let currentLine = { changes: [] };
  let lines = changelogContents.toString().split('\n');
  lines.forEach(line => {
    line = line.trim();
    if(line == '') {
      out.push(currentLine);
      currentLine = { changes: [] };
    } else if(!line.startsWith('-')) {
      let match = line.match(/[^:]*/);
      currentLine.version = match && match[0] || '???';
    } else {
      let change = line.match(/\-+\s*(.*)/);
      currentLine.changes.push(change && change[1]);
    }
  });
  return out;
}

async function upload_release() {
  const folderName = path.basename(__dirname);
  let changes;
  let version = `v${pjson.version}`;
  let changelog = 'New Update';
  const filename = path.resolve(__dirname, 'changelog.txt');
  if(fs.existsSync(filename)) {
    changes = await readChangeLog(filename);
    version = changes[0].version;
    changelog = changes[0].changes.map(v => `- ${v}`).reduce((a,b,c) => `${a}\n${b}`);
  }
  const archiveName = `${folderName}_${version}.zip`;
  let result;
  result = await octokit.request('POST /repos/{owner}/{repo}/releases', {
    owner: 'TheHorscht',
    repo: folderName,
    tag_name: version,
    name: version,
    body: changelog,
  });
  assert(result.status == 201);
  let file = await fs.readFile(path.resolve(__dirname, 'dist/', archiveName));
  let uri = uriTemplate.parse(result.data.upload_url);
  result = await axios.post(uri.expand({ name: archiveName, label: archiveName }), file, {
    headers: {
      'Accept': 'application/vnd.github.v3+json',
      'Authorization': `token ${process.env.GH_TOKEN}`,
      'Content-Type': 'application/zip, application/octet-stream',
    },
  }).catch(err => {
    console.log(`${err.response.status} - ${err.response.statusText}`);
  });
}

upload_release();
