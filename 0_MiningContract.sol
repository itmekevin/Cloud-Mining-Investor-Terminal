// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "contracts/USDT_Stuff.sol";

/*
INTENDED USAGE: This contract allows individuals to invest into a company and receive rewards after specified time intervals.
*/
contract DinelliMining is USDT_Stuff {

    uint256 public maxValueETH = 15000000000000000000;
    uint256 public constant1_ETH = 83320;
    uint256 public constant2_ETH = 957600000000000000000000;
    uint256 public fundsETH = 0;
    uint256 public investedfundsETH = 0;
    int256 private constant converter1 = 1000000000000000000;
    int256 private constant converter2 = 1000000000000000000000000000;

    mapping(address => uint256) public invest_ETH;
    mapping(address => uint256) public timeofInvest_ETH;


// INVEST FUNCTION ALLOWS FOR THE DEPOSIT OF fundsETH AND THE WITHDRAWAL OF PROFITS AT SOME TIME INTERVAL

    function ETHinvest(uint256 investment) external payable {
        address investor = msg.sender;
        require (investment == msg.value);
        require ((investedfundsETH + investment) < maxValueETH, "amount too high");
        fundsETH += investment;
        investedfundsETH += investment;
        invest_ETH[investor] += investment;
        timeofInvest_ETH[investor] = block.number;
    }

    function ETHcompound() external {
        address investor = msg.sender;
        require(invest_ETH[investor] > 0, "no investments to compound");
        require(investedfundsETH <= maxValueETH, "amount being compounded too high");
        uint256 result = dailyRateCalcETH(investor);
        timeofInvest_ETH[investor] = block.number;
        invest_ETH[investor] += result;
        investedfundsETH += result;
    }

    function ETHcollectProfit() external {
        address investor = msg.sender;
        require (invest_ETH[investor] > 0, "no investments to collect profits for");
        uint256 result = dailyRateCalcETH(investor);
        if (fundsETH > result) {
            timeofInvest_ETH[investor] = block.number;
            fundsETH -= result;
            payable(investor).transfer(result);
        } else {
            revert();
        }
    }

// CALCULATES THE DAILY RATE AND MULTIPLIES THAT BY TIME INVESTED TO DETERMINE PROFITS PER INDIVIDUAL
    function dailyRateCalcETH(address investor) internal view returns (uint256) {
        uint256 dailyRate = uint256(((int(constant1_ETH)*((getLatestPriceBTC()/getLatestPriceETH())*converter1))-int(constant2_ETH))*int(invest_ETH[investor])/converter2);
        uint256 result = dailyRate * ((block.number - timeofInvest_ETH[investor])/blocksPerDay);
        return result;
    }

// SET CONSTANTS FOR dailyRateCalc

    function setconstant1_ETH(uint256 changeconstant1_ETH) external onlyAdmin {
        constant1_ETH = changeconstant1_ETH;
    }

    function setconstant2_ETH(uint256 changeconstant2_ETH) external onlyAdmin {
        constant2_ETH = changeconstant2_ETH;
    }

// THE FOLLOWING FUNCTIONS ARE FOR OWNERSHIP TO ADD AND REMOVE fundsETH FROM THE CONTRACT BALANCE

    function addLiquidityETH(uint256 liquidETH) external payable onlyAdmin {
        require (liquidETH == msg.value);
        fundsETH += liquidETH;
    }

    function takefundsETH(address payable fundsDestination, uint256 liquidETH) external onlyAdmin {
        require (fundsDestination != address(0));
        fundsETH -= liquidETH;
        fundsDestination.transfer(liquidETH);
    }

// SETS THE MAX VALUE THAT IS ABLE TO BE INVESTED. DOES NOT IMPACT COMPOUNDING OR ADDED LIQUIDITY FROM ADMIN
    function setMaxValueETH(uint256 _MaxValue) external onlyAdmin {
        maxValueETH = _MaxValue;
    }

}
