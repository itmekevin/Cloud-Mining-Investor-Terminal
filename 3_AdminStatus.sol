// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/*
Create a list of users which should receive special privledges via the "onlyAdmin" modifier,
preventing non-admins from using certain functions.
*/

contract AdminStatus is Ownable{

    mapping(address => bool) private adminStatus;


    function grantAdmin(address admin) public onlyOwner {
        adminStatus[admin] = true;
    }

    function revokeAdmin(address admin) public onlyOwner {
        adminStatus[admin] = false;
    }

    modifier onlyAdmin() {
        require(adminStatus[msg.sender] == true);
        _;
    }

}