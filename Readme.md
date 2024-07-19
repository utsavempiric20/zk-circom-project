# Steps of Generate and Validate the proof

- node generate_witness.js moutputs.wasm input.json witness.wtns

- snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
- snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
- snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
- snarkjs groth16 setup moutputs.r1cs pot12_final.ptau moutputs_0000.zkey
- snarkjs zkey contribute moutputs_0000.zkey moutputs_0001.zkey --name="1st Contributor Name" -v
- snarkjs zkey export verificationkey moutputs_0001.zkey verification_key.json
- snarkjs groth16 prove moutputs_0001.zkey witness.wtns proof.json public.json

- snarkjs groth16 verify verification_key.json public.json proof.json
- snarkjs zkey export solidityverifier moutputs_0001.zkey verifier.sol
- snarkjs generatecall
