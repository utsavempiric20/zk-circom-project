// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Pairing.sol";

contract CustomVerifier {
    using Pairing for *;

    struct VerifyingKey {
        Pairing.G1Point alpha1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }

    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    VerifyingKey internal verifyingKey;

    constructor(
        uint[2] memory alpha1,
        uint[2][2] memory beta2,
        uint[2][2] memory gamma2,
        uint[2][2] memory delta2,
        uint[2][] memory IC
    ) {
        verifyingKey.alpha1 = Pairing.G1Point(alpha1[0], alpha1[1]);
        verifyingKey.beta2 = Pairing.G2Point(
            [beta2[0][0], beta2[0][1]],
            [beta2[1][0], beta2[1][1]]
        );
        verifyingKey.gamma2 = Pairing.G2Point(
            [gamma2[0][0], gamma2[0][1]],
            [gamma2[1][0], gamma2[1][1]]
        );
        verifyingKey.delta2 = Pairing.G2Point(
            [delta2[0][0], delta2[0][1]],
            [delta2[1][0], delta2[1][1]]
        );

        for (uint i = 0; i < IC.length; i++) {
            verifyingKey.IC.push(Pairing.G1Point(IC[i][0], IC[i][1]));
        }
    }

    function verify(
        uint[] memory input,
        Proof memory proof
    ) public view returns (bool) {
        require(
            input.length + 1 == verifyingKey.IC.length,
            "Invalid input length"
        );

        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            vk_x = Pairing.addition(
                vk_x,
                Pairing.scalar_mul(verifyingKey.IC[i + 1], input[i])
            );
        }
        vk_x = Pairing.addition(vk_x, verifyingKey.IC[0]);

        // Pairing check
        if (
            !Pairing.pairingProd4(
                proof.A,
                proof.B,
                Pairing.negate(vk_x),
                verifyingKey.gamma2,
                Pairing.negate(proof.C),
                verifyingKey.delta2,
                Pairing.negate(verifyingKey.alpha1),
                verifyingKey.beta2
            )
        ) return false;

        return true;
    }

    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[] memory input
    ) public view returns (bool) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);

        return verify(input, proof);
    }
}
