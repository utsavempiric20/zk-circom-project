pragma circom  2.0.0;

include "./node_modules/circomlib/circuits/poseidon.circom";
include "./node_modules/circomlib/circuits/bitify.circom";
include "./node_modules/circomlib/circuits/comparators.circom";
include "./node_modules/circomlib/circuits/mux1.circom";

template AadharCard(n) {

    signal input name[n];
    signal input DOB;
    signal output IdentificationNumber;
    signal output userProofNumber;
    
    component uniqueNumber = Poseidon(n+1);
    component generatedUserProof = Poseidon(1);
    component hash12 = calculateHash12();

    for (var i = 0; i < n; i++){
        uniqueNumber.inputs[i] <== name[i];
    }
    uniqueNumber.inputs[n] <== DOB;
    hash12.in1 <== uniqueNumber.out;
    
    generatedUserProof.inputs[0] <== uniqueNumber.out;

    IdentificationNumber <== hash12.out;
    userProofNumber <==  generatedUserProof.out;

    // log("IdentificationNumber --> ",IdentificationNumber);
    // log("userProofNumber --> ",userProofNumber);
}

template calculateHash12(){
    signal input in1;
    signal output out;
    
    component n2b = Num2Bits(254);
    component lessThan = LessThan(40);
    component mux = Mux1();

    n2b.in <== in1;

    var lc = 0;
    var e = 1;
    for (var i = 0; i < 40; i++){
        lc += n2b.out[i] * e;
        e = e * 2;
    }

    signal lcSignal <== lc;

    lessThan.in[0] <== lcSignal;
    lessThan.in[1] <== 900000000000;

    mux.c[0] <==  lcSignal;
    mux.c[1] <== lcSignal - 900000000000;
    mux.s <== lessThan.out;

    out <== 1000000000000 + mux.out;

    log("lcSignal : ",lcSignal);
    log("lcSignal - 900000000000 : ",lcSignal-900000000000);
    log("lessThan.out : ",lessThan.out);
    log("mux.out : ",mux.out);
    log("out : ",out);
}

component main = AadharCard(5);