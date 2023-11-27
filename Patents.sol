// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Registers {
    struct Patent {
        string owner;
        string description;
        string patent_type;
        string[] keywords;
        uint created_at;
        uint valid_range;
    }

    Patent[] public patents;

    // Public

    function newPatent(
        string memory owner,
        string memory description,
        string memory patent_type,
        string[] memory keywords
    ) public {
        uint valid_time_range = 2 * 365 days;
        uint created_at = block.timestamp;
        require(
            canAddNewPatent(patent_type, keywords, created_at),
            "Existing patent"
        );

        patents.push(Patent({
            owner: owner,
            description: description,
            patent_type: patent_type,
            keywords: keywords,
            created_at: created_at,
            valid_range: valid_time_range
        }));
    }

    function renewPatent(
        string memory owner,
        string memory patent_type,
        string[] memory keywords
    ) public {
        int pIndex = getPatentIndex(owner, patent_type, keywords);
        require(
            pIndex >= 0,
            "Patent not found"
        );
        Patent storage p = patents[uint(pIndex)];
        p.valid_range += block.timestamp + 2 * 365 days;
    }

    // Auxiliary functions

    function getPatentIndex(
        string memory owner,
        string memory patent_type,
        string[] memory keywords
    ) internal view returns (int) {
        for (int i = 0; i < int(patents.length); i++) {
            if (
                isSameString(owner, patents[uint(i)].owner) &&
                isSameString(patent_type, patents[uint(i)].patent_type) &&
                isSameStringArray(keywords, patents[uint(i)].keywords)
            ) {
                return i;
            }
        }
        return -1;
    }

    function canAddNewPatent(string memory patent_type, string[] memory keywords, uint created_at) internal view returns (bool) {
        for (uint i = 0; i < patents.length; i++) {
            if (!isSameString(patent_type, patents[i].patent_type)) continue;
            if (
                isSimilarArray(keywords, patents[i].keywords) &&
                (created_at < patents[i].created_at + patents[i].valid_range)
            ) return false;
        }
        return true;
    }

    // Utils

    function isSameStringArray(string[] memory array1, string[] memory array2) internal pure returns (bool) {
        if (array1.length != array2.length) return false;
        for (uint i = 0; i < array1.length; i++) {
            if (!isInArray(array1[i], array2)) return false;
        }
        return true;
    }

    function isInArray(string memory word, string[] memory array) internal pure returns (bool) {
        for (uint i = 0; i < array.length; i++) {
            if (isSameString(word, array[i])) return true;
        }
        return false;
    }

    function isSameString(string memory s1, string memory s2) internal pure returns (bool) {
        return keccak256(bytes(s1)) == keccak256(bytes(s2));
    }

    function isSimilarArray(string[] memory k1, string[] memory k2) internal pure returns (bool) {
        uint similarKeywords = 0;
        uint maxSimilarKeywords = 2;
        for (uint i = 0; i < k1.length; i++) {
            for (uint j = 0; j < k2.length; j++) {
                if (keccak256(bytes(k1[i])) == keccak256(bytes(k2[j]))) similarKeywords++;
            }
        }
        return similarKeywords >= maxSimilarKeywords;
    }
}