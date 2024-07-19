pragma circom 2.0.0;

// template moutputs(n) {
//     signal input inputData[n];
//     signal input expectedData;
//     signal output outputData;
    
//     component subCircuitData[n-1];
//     signal temp[n-1];
    
//     temp[0] <== inputData[0] * inputData[1];
//     for (var i = 1; i < n-1; i++){
//         subCircuitData[i] = subCircuitData();
//         subCircuitData[i].in1 <== temp[i-1];
//         subCircuitData[i].in2 <== inputData[i+1];
//         temp[i] <== subCircuitData[i].out;
//     }
//     outputData <== temp[n-2];
//     expectedData === outputData;
// }

template moutputs(n) {
    signal input inputData[n];
    signal input expectedData[n];
    signal output outputData;
    
    component subCircuitData[n];
    
    for (var i = 0; i < n; i++){
        subCircuitData[i] = subCircuitData();
        subCircuitData[i].in1 <== inputData[i];
        expectedData[i] === subCircuitData[i].out;
        log("expectedData[i] ",i,expectedData[i]);
    }
}

template subCircuitData(){
    signal input in1;
    signal output out;
    signal temp;

    temp <== in1 * in1;
    out <== temp - temp + in1;
    log("out ",out);
}   

component main {public [expectedData]} = moutputs(5);