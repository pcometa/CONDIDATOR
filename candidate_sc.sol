// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Candidate {
    //................events....................
    event becomeCandidateEvent(address _candidate,uint256 _candidatingCost,string _trackId);
    event investMentEvent(address _investor,address _candidate,uint256 _investmentAmount,string _trackId);

    //.............varaibles..............//
    address public owner;
    uint256 public startCandidatingTime;
    uint256 public endCandidatingTime;
    address public stakeContract;
    uint256 public candidatingCost;
    IERC20 public usdtContract;
    //...........................enums.......................//
    enum accessibleFunctions{
        withdrawAmount
    }
    //..............................structs............................//
    struct candidateDetails {
        uint256 totalInvestedAmount;
        uint256 investorsProfitPercentage;
    }

    struct investorDetails {
        uint256 investmentAmount;
        uint256 investmentTime;
    }

    struct addCandidatesDetails{
        address candidateAddress;
        uint256 candidateInvestorProfit;
    }
    //..........................modifiers.............................//
    modifier checkAlreadyCandidated() {
        require(
            candidats[msg.sender].investorsProfitPercentage == 0,
            "You are already a candidate"
        );
        _;
    }

    modifier onlyStakeContract(){
        require(msg.sender==stakeContract,"this function can only called by stake contract");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner of the contract");
        _;
    }

    modifier onlyOwnerAndOperators(uint8 _accessibleFunctionsId){
        if(msg.sender==owner || operators[msg.sender][_accessibleFunctionsId]){
            _;
        }
        else{
            revert("You are not the owner of the contract or you don't have access to call this function");
        }
    }
    //...................maps..........................//
    mapping(address => candidateDetails) public candidats;
    mapping(address => mapping(address => investorDetails)) public investors;
    mapping(address=>mapping (uint8 => bool))public operators;

    constructor(uint256 _startCandidatingTime, uint256 _endCandidatingTime, 
    address _stakeContractAddress,uint256 _candidatingCost,address _usdtContractAddress,address _owner
    ) {
        startCandidatingTime = _startCandidatingTime;
        endCandidatingTime = _endCandidatingTime;
        stakeContract=_stakeContractAddress;
        usdtContract=IERC20(_usdtContractAddress);
        candidatingCost=_candidatingCost;
        owner=_owner;
    }

    //......................functions.........................//

    function becomeCandidate(uint256 _investorsProfitPercentage,string memory _trackId)
        public
        checkAlreadyCandidated()
    {
        if (
            startCandidatingTime > block.timestamp ||
            endCandidatingTime < block.timestamp
        ) {
            revert("Candidating time is over or not started yet");
        }
        require(usdtContract.transferFrom(msg.sender,address(this),candidatingCost),"Transfer Faild");
        candidats[msg.sender]
            .investorsProfitPercentage = _investorsProfitPercentage;
        candidats[msg.sender].totalInvestedAmount=0;
        emit becomeCandidateEvent(msg.sender, candidatingCost,_trackId);
    }

    function investMent(
        uint256 _investmentAmount,
        address _investorAddress,
        address _candidateAddress,
        string memory _trackId
    ) public onlyStakeContract() {
        require(
            candidats[_candidateAddress].investorsProfitPercentage != 0,
            "Candidate is not found"
        );
        require(
            investors[_investorAddress][_candidateAddress].investmentAmount ==
                0,
            "You have Already invested on this candidate"
        );
        require(_investorAddress!=_candidateAddress,"You can not invest on your self");
        investors[_investorAddress][_candidateAddress]
            .investmentAmount = _investmentAmount;
        investors[_investorAddress][_candidateAddress].investmentTime=block.timestamp;
        candidats[_candidateAddress].totalInvestedAmount += _investmentAmount;
        emit investMentEvent(_investorAddress,_candidateAddress,_investmentAmount,_trackId);
    }

    function getInvestorDetails(
        address _investorAddress,
        address _validatorAddress
    )
        public
        view
        returns (
            uint256 investmentAmount,
            uint256 validatorTotalInvestedAmount
        )
    {
        require(investors[_investorAddress][_validatorAddress].investmentAmount!=0,"You are not invest on this validator");
        return (investors[_investorAddress][_validatorAddress].investmentAmount,candidats[_validatorAddress].totalInvestedAmount);
    }

    function withdrawAmount(uint256 _amount)public onlyOwnerAndOperators(0){
        require(usdtContract.balanceOf(address(this))>=_amount,"The balance of the contract is not enough");
        require(usdtContract.transfer(msg.sender, _amount),"Transfer failed");
    }

    function addOperator(address _operator,uint8 _accessibleFunctionsId)public onlyOwner(){
        require(!operators[_operator][_accessibleFunctionsId],"operator is already added");
        operators[_operator][_accessibleFunctionsId]=true;
    }

    function removeOperator(address _operator,uint8 _accessibleFunctionsId)public onlyOwner(){
        require(operators[_operator][_accessibleFunctionsId],"operator is not found");
        delete operators[_operator][_accessibleFunctionsId];
    }

    function updateStakeContract(address _stakeContractAddress)public onlyOwner(){
        stakeContract=_stakeContractAddress;
    }

    function addCandidates(addCandidatesDetails[] memory _candidates)public onlyOwner(){
        for (uint256 i=0; i<_candidates.length; i++)
        {
            candidats[_candidates[i].candidateAddress].investorsProfitPercentage=_candidates[i].candidateInvestorProfit;
            candidats[_candidates[i].candidateAddress].totalInvestedAmount=0;
        }
    }
}
