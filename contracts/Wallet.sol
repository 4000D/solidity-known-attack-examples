pragma solidity ^0.4.24;

import {ERC20} from "./zeppelin/token/ERC20/ERC20.sol";

contract WalletLibrary {
  address public owner;
  address public lib;
  mapping (address => bool) public isWallet;

  modifier auth(address _addr) {
    reuqire(owner == _addr || lib == _addr || isWallet[_addr]);
    _;
  }

  function setWallet() public {
    require(!isWallet[msg.sender]);
    require(isContract(msg.sender));
    isWallet[addr] = true;
  }

  function transferOwnership(address _next) public auth {
    owner = _next;
  }

  function withdraw(ERC20 _token, uint _amount) public auth {
    if (address(_token) == 0) {
      msg.sender.transfer(_amount);
    } else {
      require(_token.transfer(msg.sender, _amount));
    }
  }

  function isContract(address _addr) view internal returns (bool) {
    uint size;
    if (_addr == 0) return false;
    assembly {
      size := extcodesize(_addr)
    }
    return size>0;
  }
}


contract Wallet {
  address public owner;
  address public lib;

  function Wallet(address _lib) public {
    lib = _lib;
    WalletLibrary(_lib).setWallet();
  }

  function() public payable {
    require(lib.delefgatecall.value(msg.value)(msg.data));
  }
}