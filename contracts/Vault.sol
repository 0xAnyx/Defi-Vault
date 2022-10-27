// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;
import "./interfaces/IERC20.sol";

contract DefiVault {

    IERC20 public immutable token;

    mapping (address => uint) public sharesOf;
    uint public totalShares;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function _mintShares(address _to, uint _amount) internal {
        sharesOf[_to] += _amount;
        totalShares += _amount;
    }

    function _burnShares(address _to, uint _amount) internal {
        sharesOf[_to] -= _amount;
        totalShares -= _amount;
    }

    function deposit(uint _amount) external {
        uint shares;
        if(totalShares == 0) {
            shares = _amount;
        }
        else {
            // s = a * T / B
            shares = (_amount * totalShares) / token.balanceOf(address (this));
        }

        _mintShares(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint _sharesToBurn) external {
        // dx = s/T * Bal
        uint withdrawal = (sharesOf[msg.sender] * token.balanceOf(address (this)) / totalShares);
        _burnShares(msg.sender, _sharesToBurn);
        token.transfer(msg.sender, withdrawal);
    }

}