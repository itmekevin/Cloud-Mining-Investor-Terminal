//SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "contracts/3_AdminStatus.sol";
import "contracts/4_PriceChecker.sol";

/*
INTENDED USAGE: This contract allows individuals to invest into a company and receive rewards after specified time intervals using USDC (could use any ERC20).
*/
contract USDC_Stuff is AdminStatus, BTC_Oracle_Test {

    uint256 public constant1_Stables = 4104;
    uint256 public constant2_Stables = 9576000000000000;
    uint256 public maxValueStables = 50000000000;
    uint256 public fundsUSDC = 0;
    uint256 public investedFundsUSDC = 0;
    uint256 public blocksPerDay = 6375;
    uint256 public constant converter3 = 10000000000000000000;

    mapping(address => uint256) public invest_USDC;
    mapping(address => uint256) public timeofInvest_USDC;

    IERC20 public immutable USDC;

constructor () {
    USDC = IERC20(0x07865c6E87B9F70255377e024ace6630C1Eaa37F);
    }

// INVESTING LOGIC FLOW
    function USDCInvest(uint256 investment) external payable {
        address investor = msg.sender;
        require (investedFundsUSDC + investment <= maxValueStables, "amount too high");
        require (USDC.allowance(msg.sender, address(this)) > investment);
        fundsUSDC += investment;
        investedFundsUSDC += investment;
        invest_USDC[investor] += investment;
        timeofInvest_USDC[investor] = block.number;
        USDC.transferFrom(investor, address(this), investment);
    }

    function USDCcompound() external {
        address investor = msg.sender;
        require(invest_USDC[investor] > 0, "no investment to compound");
        require(investedFundsUSDC <= maxValueStables, "amount being compounded too high");
        uint256 result = dailyRateCalcUSDC(investor);
        timeofInvest_USDC[investor] = block.number;
        invest_USDC[investor] += result;
        investedFundsUSDC += result;
    }

    function USDCcollectProfit() external {
        address investor = msg.sender;
        require(invest_USDC[investor] > 0, "no investment to collect profits for");
        uint256 result = dailyRateCalcUSDC(investor);
        if (fundsUSDC > result) {
            timeofInvest_USDC[investor] = block.number;
            fundsUSDC -= result;
            USDC.transfer(investor, result);
            } else {
                revert();
            }
    }

// CALCULATE THE DAILY RATE HERE, THEN MULTIPLY IT BY DAYS INVESTED
    function dailyRateCalcUSDC(address investor) internal view returns (uint256) {
        uint256 dailyRate = uint256((((constant1_Stables*(uint(getLatestPriceBTC())))-constant2_Stables)*invest_USDC[investor])/converter3);
        uint256 result = dailyRate * ((block.number - timeofInvest_USDC[investor])/blocksPerDay);
        return result;
    }

// SET CONSTANTS FOR dailyRateCalcUSDC
    function setconstant1_Stables(uint256 changeconstant1_Stables) external onlyAdmin {
        constant1_Stables = changeconstant1_Stables;
    }

    function setconstant2_Stables(uint256 changeconstant2_Stables) external onlyAdmin {
        constant2_Stables = changeconstant2_Stables;
    }

// FUNCTIONS TO ALLOW OWNERSHIP TO ADD AND REMOVE FUNDS FROM THE CONTRACT BALANCE
    function addLiquidityUSDC(uint256 liquidUSDC) external payable onlyAdmin {
        require (USDC.allowance(msg.sender, address(this)) > liquidUSDC, "increase allowance");
            fundsUSDC += liquidUSDC;
            USDC.transferFrom(msg.sender, address(this), liquidUSDC);
    }

    function takeFundsUSDC(address fundsDestination, uint256 liquidUSDC) external onlyAdmin {
        require (fundsDestination != address(0));
        fundsUSDC -= liquidUSDC;
        USDC.transfer(fundsDestination, liquidUSDC);
    }

    function setMaxValueStables(uint256 newMaxValue) external onlyAdmin {
        maxValueStables = newMaxValue;
    }
}
