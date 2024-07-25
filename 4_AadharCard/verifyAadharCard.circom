pragma circom  2.0.0;

include "./node_modules/circomlib/circuits/poseidon.circom";
include "./node_modules/circomlib/circuits/comparators.circom";

template verifyAadharCard() {
    signal input storedUserHash;
    signal input userProofNumber;
    signal output isValid;

    component generatedUserProof = Poseidon(1);
    generatedUserProof.inputs[0] <== storedUserHash;

    component equalProof = IsEqual();
    equalProof.in[0] <== userProofNumber;
    equalProof.in[1] <== generatedUserProof.out;

    log("storedUserHash     : ",storedUserHash);
    log("userProofNumber    : ",userProofNumber);
    log("generatedUserProof : ",userProofNumber);
    isValid <== equalProof.out;
    log("isValid            : ",isValid);
}

component main = verifyAadharCard();