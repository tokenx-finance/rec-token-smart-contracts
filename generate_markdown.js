const fs = require('fs');

function jsonToMarkdown(jsonData) {
  let markdown = '| File                               | Lines Covered | Total Lines | Functions Covered | Total Functions | Branches Covered | Total Branches |\n';
  markdown += '|------------------------------------|---------------|-------------|-------------------|-----------------|------------------|----------------|\n';

  for (const filePath in jsonData) {
    const coverageData = jsonData[filePath];
    const linesCovered = Object.values(coverageData.l).reduce((acc, val) => acc + val, 0);
    const totalLines = Object.keys(coverageData.l).length + linesCovered;
    const functionsCovered = Object.keys(coverageData.fnMap).length;
    const totalFunctions = Object.keys(coverageData.f).length;
    const branchesCovered = Object.keys(coverageData.branchMap).length;
    const totalBranches = Object.keys(coverageData.b).length;

    markdown += `| ${filePath} | ${linesCovered} | ${totalLines} | ${functionsCovered} | ${totalFunctions} | ${branchesCovered} | ${totalBranches} |\n`;
  }

  return markdown;
}

// Example usage
const jsonFilePath = './coverage.json';
fs.readFile(jsonFilePath, 'utf8', (err, data) => {
  if (err) {
    console.error(`Error reading JSON file: ${err}`);
    return;
  }

  const jsonData = JSON.parse(data);
  const markdown = jsonToMarkdown(jsonData);
  console.log(markdown);
});
