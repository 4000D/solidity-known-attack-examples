pragma solidity ^0.4.24;

import {ERC20} from "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract Logger {
  event Log(string _msg);
  function log(string _msg) external {
    emit Log(_msg);
  }
}

contract WalletLibrary is Logger {
  address public owner;
  address public lib;
  mapping (address => bool) public isWallet;

  modifier auth(address _addr) {
    require(owner == _addr || lib == _addr || isWallet[_addr]);
    _;
  }

  constructor() public payable {}

  function () public payable {}

  function initWallet() public {
    require(owner == address(0));
    owner = msg.sender;

    WalletLibrary(lib).setWallet();
  }

  function setWallet() public {
    require(!isWallet[msg.sender]);
    require(isContract(msg.sender));
    isWallet[msg.sender] = true;
  }

  function transferOwnership(address _next) public auth(msg.sender) {
    owner = _next;
  }

  function withdraw(ERC20 _token, uint _amount) public auth(msg.sender) {
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
  uint256 internal constant FWD_GAS_LIMIT = 10000;

  address public owner;
  address public lib;

  constructor(address _lib) public payable {
    lib = _lib;
  }

  function() public payable {
    address _dst = lib;
    uint256 fwdGasLimit = FWD_GAS_LIMIT;
    bytes memory _calldata = msg.data;

    assembly {
      let result := delegatecall(sub(gas, fwdGasLimit), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
      let size := returndatasize
      let ptr := mload(0x40)
      returndatacopy(ptr, 0, size)

      // revert instead of invalid() bc if the underlying call failed with invalid() it already wasted gas.
      // if the call returned error data, forward it
      switch result case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}