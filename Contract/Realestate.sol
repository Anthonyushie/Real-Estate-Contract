// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract RealEstateInvestmentContract {
    struct Property {
        // string propertyType;
        // string location;
        uint256 price;
        uint256 rentalIncome;
        uint256 vacancyRate;
    }

    struct Investment {
        address investor;
        uint256 amount;
    }

    mapping(address => uint256) public balances;
    mapping(address => Property[]) public portfolios;
    mapping(address => Investment[]) public investments;

    AggregatorV3Interface private priceFeed;
    AggregatorV3Interface private rentalIncomeFeed;
    AggregatorV3Interface private vacancyRateFeed;

    uint256 private constant MAX_INVESTMENT = 1 ether;

    event Invested(
        address indexed investor,
        // string propertyType,
        // string location,
        uint256 amount
    );

    constructor(
        address _priceFeed,
        address _rentalIncomeFeed,
        address _vacancyRateFeed
    ) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        rentalIncomeFeed = AggregatorV3Interface(_rentalIncomeFeed);
        vacancyRateFeed = AggregatorV3Interface(_vacancyRateFeed);
    }

    function invest(
        // string memory _propertyType,
        // string memory _location,
        uint256 _amount
    ) public {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            _amount <= MAX_INVESTMENT,
            "Amount must be less than or equal to the maximum investment amount"
        );

        (uint256 price, uint256 rentalIncome, uint256 vacancyRate) = getPropertyData(
            // _propertyType,
            // _location
        );

        require(price > 0, "Property does not exist");
        require(vacancyRate < 10, "Vacancy rate is too high");
        require(
            price <= _amount,
            "Investment amount is less than the property price"
        );

        balances[msg.sender] -= _amount;
        portfolios[msg.sender].push(
            // Property(_propertyType, _location, price, rentalIncome, vacancyRate)
            Property(price, rentalIncome, vacancyRate)
        );
        investments[msg.sender].push(Investment(msg.sender, _amount));

        // Transfer funds to seller
        address payable seller = payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4); // Replace with actual seller address
        seller.transfer(_amount);

        emit Invested(msg.sender, /*_propertyType, _location,*/ _amount);
    }

    function getPropertyData(
        // string memory _propertyType,
        // string memory _location
    ) private view returns (uint256, uint256, uint256) {
        uint256 price = getPrice(/*_propertyType, _location*/);
        uint256 rentalIncome = getRentalIncome(/*_propertyType, _location*/);
        uint256 vacancyRate = getVacancyRate(/*_propertyType, _location*/);

        return (price, rentalIncome, vacancyRate);
    }

    function getPrice(
        // string memory _propertyType,
        // string memory _location
    ) private view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function getRentalIncome(
        // string memory _propertyType,
        // string memory _location
    ) private view returns (uint256) {
        (, int256 rentalIncome, , , ) = rentalIncomeFeed.latestRoundData();
        return uint256(rentalIncome);
    }

    function getVacancyRate(
        // string memory _propertyType,
        // string memory _location
    ) private view returns (uint256) {
        (, int256 vacancyRate, , , ) = vacancyRateFeed.latestRoundData();
        return uint256(vacancyRate);
    }
}
