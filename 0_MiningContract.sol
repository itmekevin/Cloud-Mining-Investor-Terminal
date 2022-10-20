// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "contracts/1_USDT.sol";


/*
INTENDED USAGE: This contract allows individuals to invest into a company and receive rewards after specified time intervals.
*/
contract DinelliMining is USDT_Stuff {

    uint256 public maxValueETH = 15000000000000000000;
    uint256 public constant1_ETH = 83320;
    uint256 public constant2_ETH = 957600000000000000000000;
    uint256 public fundsETH = 0;
    uint256 public investedfundsETH = 0;

    mapping(address => uint256) public invest_ETH;
    mapping(address => uint256) public timeofInvest_ETH;
    mapping(address => uint256) public investmentRewards_ETH;


// INVEST FUNCTION ALLOWS FOR THE DEPOSIT OF fundsETH AND THE WITHDRAWAL OF PROFITS AT SOME TIME INTERVAL

    function ETHinvest(uint256 investment) public payable {
        address investor = msg.sender;
        require ((investedfundsETH + investment) < maxValueETH);
        fundsETH += investment;
        investedfundsETH += investment;
        invest_ETH[investor] += investment;
        timeofInvest_ETH[investor] = block.number;
    }

    function ETHcompound() public {
        address investor = msg.sender;
        require(invest_ETH[investor] > 0);
        require(investedfundsETH <= maxValueETH);
        dailyRateCalcETH(investor);
        timeofInvest_ETH[investor] = block.number;
        invest_ETH[investor] += investmentRewards_ETH[investor];
        investedfundsETH += investmentRewards_ETH[investor];
    }

    function ETHcollectProfit() public {
        address investor = msg.sender;
        require (invest_ETH[investor] > 0);
        dailyRateCalcETH(investor);
        timeofInvest_ETH[investor] = block.number;
        fundsETH -= investmentRewards_ETH[investor];
        payable(investor).transfer(investmentRewards_ETH[investor]);
    }

// CALCULATES THE DAILY RATE AND MULTIPLIES THAT BY TIME INVESTED TO DETERMINE PROFITS PER INDIVIDUAL

    function dailyRateCalcETH(address investor) internal {
        uint256 dailyRate = uint256(((int(constant1_ETH)*((getLatestPriceBTC()/getLatestPriceETH())*int(1000000000000000000)))-int(constant2_ETH))*int(invest_ETH[investor])/int(1000000000000000000000000000));
        investmentRewards_ETH[investor] = dailyRate * ((block.number - timeofInvest_ETH[investor])/6375);
    }

// SET CONSTANTS FOR dailyRateCalc

    function setconstant1_ETH(uint256 changeconstant1_ETH) public onlyAdmin {
        constant1_ETH = changeconstant1_ETH;
    }

    function setconstant2_ETH(uint256 changeconstant2_ETH) public onlyAdmin {
        constant2_ETH = changeconstant2_ETH;
    }

// THE FOLLOWING FUNCTIONS ARE FOR OWNERSHIP TO ADD AND REMOVE fundsETH FROM THE CONTRACT BALANCE

    function addLiquidityETH() public payable onlyAdmin {
        fundsETH += msg.value;
    }

    function takefundsETH(address payable treasury, uint256 liquidETH) public onlyAdmin{
        fundsETH -= liquidETH;
        treasury.transfer(liquidETH);
    }

// SETS THE MAX VALUE THAT IS ABLE TO BE INVESTED. DOES NOT IMPACT COMPOUNDING OR ADDED LIQUIDITY FROM ADMIN
    function setMaxValueETH(uint256 newMaxValue) public onlyAdmin {
        maxValueETH = newMaxValue;
    }

}
