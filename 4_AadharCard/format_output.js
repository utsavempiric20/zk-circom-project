const fs = require("fs");

const rawData = fs.readFileSync("public.json");
const data = JSON.parse(rawData);

const transformedData = {
  IdentificationNumber: data[0],
  userProofNumber: data[1],
};

fs.writeFileSync(
  "formatted_output.json",
  JSON.stringify(transformedData, null, 2)
);

console.log("Formatted output written to formatted_output.json");
