// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract BTC_Oracle_Test {


    AggregatorV3Interface internal priceFeed;
    AggregatorV3Interface internal priceFeedETH;

    /**
     * Network: Mainnet
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0xf4030086522a5beea4988f8ca5b36dbc97bee88c);
        priceFeedETH = AggregatorV3Interface(0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419);
    }

    /**
     * Returns the latest price
     */
    function getLatestPriceBTC() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

        function getLatestPriceETH() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeedETH.latestRoundData();
        return price;
    }

}