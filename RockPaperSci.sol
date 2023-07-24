pragma solidity ^0.8.4;
// this contract is a simple ROCK PAPER SCiSSORS GAME that uses commitment scheme to avoid scamming
// by sending the Hash of the move  alongside with a nonce
contract RockPaperSci {

    address public ContestManger;
    address public Player1;
    address public Player2;
    uint reward;
    uint deadline; //deadline of sending the Hash of the move alongside with the randomness
    uint revealend;
    bytes32 MovePlayer1Hashed; // hash of move player1
    bytes32 MovePlayer2Hashed; // hash of move player2
    bytes32 Random1; // randomness of player1
    bytes32 Random2; // randomness of player2
    bool fake1; // flag used to check if the player revealed the correct move and randomness
    bool fake2;
    uint move1; // if move == 0 move=rock
                // if move == 1 move=paper
                // if move == 2 move=scissor 
    uint move2;
    uint winner; //winner = 1 if player 1 is the winner and winner = 2 if player 2 is the winner 
    uint reward1; //reward of player 1 
    uint reward2; // reward of player 2
    uint CountMoves;

     modifier onlyBeforeSubmitting() {
       require(block.timestamp < deadline, "Deadline has passed");
        _;
    }
      modifier onlyAfterSubmitting() {
       require(block.timestamp < deadline, "Deadline has not been passed");
        _;
    }
    
        modifier onlyBeforeRevealingDeadline() {
       require(block.timestamp < revealend, "Reveal deadline has passed");
        _;
    }
     modifier onlyAfterRevealingDeadline() {
       require(block.timestamp > revealend, "Reveal deadline has passed");
        _;
    }
      modifier onlyPlayers() {
       require(msg.sender == Player1 || msg.sender == Player2, "Only Players can vote");
        _;
    }
    // the constructor takes the address of player 1 and 2 and the valye of the reward and the deadline
    // of sending the hash and the deadline of the revealing 
    constructor(address _Player1,address _Player2,uint _reward,uint _deadline,uint _revealend) payable{
            ContestManger = msg.sender;
            Player1=_Player1;
            Player2=_Player2;
            reward=_reward;
            deadline = block.timestamp + _deadline;
            revealend = deadline + _revealend;
            CountMoves=0;
            fake1=true;
            fake2=true;
    }

    // Players can send their hashed move here
    function VoteHashed(bytes32 move) external onlyBeforeSubmitting onlyPlayers{
        if(msg.sender==Player1)
        {
            MovePlayer1Hashed=move;

        }
        else 
        {
            MovePlayer2Hashed=move;
        }
    }

    // the players Reveal their move and nonce before the deadline of the reveal deadline
    function Reveal(uint move, bytes32 randomness) external  onlyBeforeRevealingDeadline onlyAfterSubmitting  onlyPlayers{
        require(msg.sender==ContestManger);
        if(msg.sender==Player1)
        {
            move1=move;
            Random1=randomness;
            if(MovePlayer1Hashed==keccak256(abi.encodePacked(move1,Random1))){
                fake1=false;
            }
        }
        else 
        {
            move2=move;
            Random2=randomness;
               if(MovePlayer1Hashed==keccak256(abi.encodePacked(move1,Random1))){
                fake2=false;
            }
        }
        CountMoves+=1;
        // if both payers submitted their moves 
        if(CountMoves==2)
        {
            RevealWinner();
        }
    }

    // this function is usd to decide who won
    function RevealWinner() internal  {
        if(fake1 && !fake2)
        {
            winner=2;
        }
        else if (!fake1 && fake2)
        {
            winner=1;
        }
        else if (!fake1 && !fake2)
        {
            decidewinner();
        }
    }

    function decidewinner() internal {
        if(move1==move2){
            reward1=reward/2;
            reward2=reward1;
        }
        // move1=rock move2= paper   || move 1 = sci move2 = rock|| move1=paper move2=sci
        else if(move1==0 && move2==1 || move1==2 && move2==0     || move1==1 && move2==2)
        {
            reward2=reward;
            reward2=0;
        } // move1 = paper move2=rock|| move 1 = rock move2 = sci|| move1=sci move2=paper
        else if(move1==1 && move2==0 || move1==0 && move2==2     || move1==2 && move2==1)
        {
            reward1=reward;
            reward2=0;
        }
    }


    // only the ContestManger can send the reward
    function SendReward() external onlyAfterRevealingDeadline {
        require(msg.sender==ContestManger);
        if(reward1!=0)
        {
            payable(Player1).transfer(reward1);
            reward1=0;
        }
            if(reward2!=0)
        {
            payable(Player2).transfer(reward2);
            reward2=0;
        }
    }
}













