pragma circom  2.0.0;

include "./node_modules/circomlib/circuits/poseidon.circom";
include "./node_modules/circomlib/circuits/bitify.circom";
include "./node_modules/circomlib/circuits/comparators.circom";
include "./node_modules/circomlib/circuits/mux1.circom";

template AadharCard(max_name_length,max_biometric_data) {

    signal input name[max_name_length];
    signal input bioMetricData[max_biometric_data];
    signal input nameSize;
    signal input bioMetricDataSize;
    signal input DOB;
    signal input registerTime;
    signal output IdentificationNumber;
    signal output userProofNumber;

    assert(nameSize > 0 && nameSize <= max_name_length);
    assert(bioMetricDataSize > 0 && bioMetricDataSize <= max_biometric_data);

    signal intermidate_name[max_name_length];
    signal intermidate_biometric[max_biometric_data];

    signal sum_name[max_name_length+1];
    signal sum_biometric[max_biometric_data+1];

    // For name
    sum_name[0] <== 0;
    for (var i = 0; i < max_name_length; i++){
        intermidate_name[i] <== name[i] * (i+1);
        sum_name[i+1] <== sum_name[i] + intermidate_name[i];
    }

    // For biometric
    sum_biometric[0] <== 0;
    for (var i = 0; i < max_biometric_data; i++){
        intermidate_biometric[i] <== bioMetricData[i] * (i+1);
        sum_biometric[i+1] <== sum_biometric[i] + intermidate_biometric[i];
    }

    component uniqueNumber = calculatUniqueHash12();
    uniqueNumber.in1 <== sum_name[max_name_length] + sum_biometric[max_biometric_data] + DOB + registerTime;

    component generatedUserProof = Poseidon(1);
    generatedUserProof.inputs[0] <== uniqueNumber.out;

    IdentificationNumber <== uniqueNumber.out;
    userProofNumber <==  generatedUserProof.out;
    log(IdentificationNumber);
    log(userProofNumber);
}

template calculatUniqueHash12(){
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
}

template calculateProofHash(){
    signal input in1;
    signal output out;
    
    component n2b = Num2Bits(254);
    component lessThan = LessThan(60);
    component mux = Mux1();

    n2b.in <== in1;

    var lc = 0;
    var e = 1;
    for (var i = 0; i < 60; i++){
        lc += n2b.out[i] * e;
        e = e * 2;
    }

    signal lcSignal <== lc;
    log("lc : ",lc);
    log("lcsignal : ",lcSignal);

    lessThan.in[0] <== lcSignal;
    lessThan.in[1] <== 900000000000000000;

    mux.c[0] <==  lcSignal;
    mux.c[1] <== lcSignal - 900000000000000000;
    mux.s <== lessThan.out;

    out <== 1000000000000000000 + (mux.out * 99999999999999999);
}

component main = AadharCard(255,255);

    // component uniqueNumber = Poseidon(max_name_length+1);
    // component generatedUserProof = Poseidon(1);

    // for (var i = 0; i < max_name_length; i++){
    //     uniqueNumber.inputs[i] <== name[i];
    // }
    // uniqueNumber.inputs[max_name_length] <== DOB;
    // hash12.in1 <== uniqueNumber.out;
    
    // generatedUserProof.inputs[0] <== uniqueNumber.out;

    // IdentificationNumber <== hash12.out;
    // userProofNumber <==  generatedUserProof.out;
