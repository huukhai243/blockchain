// SPDX-License-Identifier: UNLICENSED

// DO NOT MODIFY BELOW THIS
pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract Splitwise {
// DO NOT MODIFY ABOVE THIS

// ADD YOUR CONTRACT CODE BELOW

    mapping(address => mapping(address => uint32)) private debts;

    function lookup(address debtor, address creditor) public view returns (uint32 ret) {
        return debts[debtor][creditor];
    }

    // msg.sender now owes `amount` more to `creditor`.
    // `path` lists the debts leading from `creditor` back to msg.sender that this IOU
    // closes into a cycle, or is empty if there is no cycle. It comes from the client,
    // so every edge is checked here: only real debts on a closed walk through this IOU
    // can be reduced, which leaves each user's net balance unchanged.
    function add_IOU(address creditor, uint32 amount, address[] calldata path) public {
        require(amount > 0, "Amount must be positive");
        require(creditor != msg.sender, "Cannot owe yourself");

        debts[msg.sender][creditor] += amount;
        if (path.length == 0) return;

        require(path[0] == creditor && path[path.length - 1] == msg.sender, "Path is not a cycle");

        uint32 minDebt = debts[msg.sender][creditor];
        for (uint256 i = 0; i + 1 < path.length; i++) {
            uint32 debt = debts[path[i]][path[i + 1]];
            require(debt > 0, "Path uses a missing debt");
            if (debt < minDebt) minDebt = debt;
        }

        for (uint256 i = 0; i + 1 < path.length; i++) {
            debts[path[i]][path[i + 1]] -= minDebt;
        }
        debts[msg.sender][creditor] -= minDebt;
    }
}
