// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./BigNumbers.sol";

/**
 * @title StringExtensions
 * @dev Extension methods for BigNumbers library to handle string conversions
 */
library StringExtensions {
    /**
     * @dev Converts a decimal string to a BigNumber
     * @param decimalStr The decimal string to convert
     * @return A BigNumber representation of the string
     */
    function fromString(string memory decimalStr) public view returns (BigNumber memory) {
        bytes memory strBytes = bytes(decimalStr);
        require(strBytes.length > 0, "Empty string");

        bool neg = false;
        uint256 startIndex = 0;

        // Check for negative sign (-)
        if (strBytes[0] == 0x2D) {
            neg = true;
            startIndex = 1;
        }

        // Initialize result as 0
        BigNumber memory result = BigNumbers.zero();
        BigNumber memory ten = BigNumbers.init(10, false);

        // Process each digit
        for (uint256 i = startIndex; i < strBytes.length; i++) {
            // Convert char to digit and validate it's a digit
            uint8 digit = uint8(strBytes[i]) - 48;
            require(digit < 10, "Invalid character in decimal string");

            // result = result * 10 + digit
            result = BigNumbers.mul(result, ten);
            result = BigNumbers.add(result, BigNumbers.init(uint256(digit), false));
        }

        // Set sign
        result.neg = neg;

        return result;
    }

    /**
     * @dev Converts a BigNumber to a decimal string
     * @param bn The BigNumber to convert
     * @return A string representation of the BigNumber
     */
    function toString(BigNumber memory bn) public view returns (string memory) {
        if (bn.bitlen == 0) {
            bytes memory result = new bytes(1);
            result[0] = 0x30; // "0"
            return string(result);
        }

        // Handle negative sign
        bool isNegative = bn.neg;

        // Make a copy of the BigNumber to work with
        BigNumber memory bnCopy = BigNumbers.init(bn.val, bn.neg, bn.bitlen);
        bnCopy.neg = false; // Work with absolute value

        // Convert to hex string first
        bytes memory hexBytes = bnCopy.val;
        bytes memory hexString = new bytes(hexBytes.length * 2);
        for (uint256 i = 0; i < hexBytes.length; i++) {
            bytes1 b = hexBytes[i];
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            hexString[2 * i] = char(hi);
            hexString[2 * i + 1] = char(lo);
        }

        // Remove leading zeros
        uint256 startIndex = 0;
        while (startIndex < hexString.length && hexString[startIndex] == "0") {
            startIndex++;
        }

        // Construct final string
        bytes memory finalResult;
        if (isNegative) {
            finalResult = new bytes(hexString.length - startIndex + 1);
            finalResult[0] = 0x2D; // "-"
            for (uint256 i = 0; i < hexString.length - startIndex; i++) {
                finalResult[i + 1] = hexString[startIndex + i];
            }
        } else {
            finalResult = new bytes(hexString.length - startIndex);
            for (uint256 i = 0; i < hexString.length - startIndex; i++) {
                finalResult[i] = hexString[startIndex + i];
            }
        }

        return string(finalResult);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    /**
     * @dev Converts a hex string to a BigNumber
     * @param hexStr The hex string to convert (with or without 0x prefix)
     * @return A BigNumber representation of the hex string
     */
    function fromHexString(string memory hexStr) public view returns (BigNumber memory) {
        bytes memory strBytes = bytes(hexStr);
        require(strBytes.length > 0, "Empty string");

        uint256 startIndex = 0;
        // Check for "0x" prefix
        if (strBytes.length >= 2 && strBytes[0] == 0x30 && (strBytes[1] == 0x78 || strBytes[1] == 0x58)) {
            startIndex = 2;
        }

        bytes memory hexValue = new bytes((strBytes.length - startIndex + 1) / 2);
        uint256 j = 0;

        // Process each hex character
        for (uint256 i = startIndex; i < strBytes.length; i += 2) {
            uint8 highNibble = _hexCharToNibble(strBytes[i]);
            uint8 lowNibble = 0;

            if (i + 1 < strBytes.length) {
                lowNibble = _hexCharToNibble(strBytes[i + 1]);
            }

            hexValue[j++] = bytes1((highNibble << 4) | lowNibble);
        }

        // Trim array if needed
        assembly {
            mstore(hexValue, j)
        }

        return BigNumbers.init(hexValue, false);
    }

    /**
     * @dev Converts a BigNumber to a hex string
     * @param bn The BigNumber to convert
     * @return A hex string representation of the BigNumber (with 0x prefix)
     */
    function toHexString(BigNumber memory bn) public pure returns (string memory) {
        if (bn.bitlen == 0) {
            bytes memory result = new bytes(3);
            result[0] = 0x30; // "0"
            result[1] = 0x78; // "x"
            result[2] = 0x30; // "0"
            return string(result);
        }

        bytes memory hexString = new bytes(bn.val.length * 2 + 2);
        hexString[0] = 0x30; // "0"
        hexString[1] = 0x78; // "x"

        bytes memory val = bn.val;
        uint256 hexIndex = 2;

        for (uint256 i = 0; i < val.length; i++) {
            uint8 b = uint8(val[i]);
            hexString[hexIndex++] = _nibbleToHexChar(b >> 4);
            hexString[hexIndex++] = _nibbleToHexChar(b & 0x0F);
        }

        return string(hexString);
    }

    /**
     * @dev Helper function to convert a hex character to its nibble value
     */
    function _hexCharToNibble(bytes1 c) private pure returns (uint8) {
        if (c >= 0x30 && c <= 0x39) return uint8(c) - 0x30; // "0"-"9"
        if (c >= 0x61 && c <= 0x66) return 10 + uint8(c) - 0x61; // "a"-"f"
        if (c >= 0x41 && c <= 0x46) return 10 + uint8(c) - 0x41; // "A"-"F"
        revert("Invalid hex character");
    }

    /**
     * @dev Helper function to convert a nibble value to its hex character
     */
    function _nibbleToHexChar(uint8 nibble) private pure returns (bytes1) {
        if (nibble < 10) return bytes1(nibble + 0x30); // "0"-"9"
        return bytes1(nibble - 10 + 0x61); // "a"-"f"
    }
}
