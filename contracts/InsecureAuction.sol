// https://consensys.github.io/smart-contract-best-practices/known_attacks/#dos-with-unexpected-revert
pragma solidity ^0.4.18;

contract InsecureAuction {
    address currentLeader;
    uint highestBid;

    /* function InsecureAuction() payable {} */

    function bid() payable {
        require(msg.value > highestBid);

        require(currentLeader.send(highestBid)); // Refund the old leader, if it fails then revert

        currentLeader = msg.sender;
        highestBid = msg.value;
    }
}
