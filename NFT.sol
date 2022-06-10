// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a-upgradeable/contracts/ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
contract NFT is
Initializable,
UUPSUpgradeable ,

    ERC721AUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable 
{
    using Strings for uint256;
    string public extension;
    uint256 MAX_MINTS;
    uint256 MAX_SUPPLY;
    uint256 public mintRate;
    uint256 public whiteListRate;

    bool public iswhiteListSale;

    string public baseURI;
    bytes32 public whitelistMerkleRoot;

    function initialize() public initializerERC721A initializer {
        __ERC721A_init("NFT", "NFT");
        __Ownable_init();
        __UUPSUpgradeable_init();
  
        extension = ".json";
        MAX_MINTS = 88;
        MAX_SUPPLY = 10021;
        mintRate = 0.0069 ether;
        whiteListRate = 0.5 ether;
        iswhiteListSale = true;
        iswhiteListSale = true;
        baseURI = "ipfs://bafybeih6g4g7ul4s3l2b6axygpf7s6fkpwhd6e5elgl2t7gmdwlc6lsmjq/metadata/";
      
    }

    

    function mint(uint256 quantity) external payable nonReentrant     {
        require(!iswhiteListSale, "Public Sale Not Live");
        // _safeMint's second argument now takes in a quantity, not a tokenId.
        require(
            quantity + _numberMinted(msg.sender) <= MAX_MINTS,
            "Exceeded the limit"
        );
        require(
            totalSupply() + quantity <= MAX_SUPPLY,
            "Not enough tokens left"
        );
        require(msg.value >= (mintRate * quantity), "Not enough ether sent");
        _safeMint(msg.sender, quantity);
    }

    function mintWhitelist(uint256 quantity, bytes32[] calldata merkleProof)
    nonReentrant    
        public
        payable
    {
        isValidMerkleProof(merkleProof, whitelistMerkleRoot);
        isCorrectPayment(whiteListRate, quantity, msg.value);
        require(
            quantity + _numberMinted(msg.sender) <= MAX_MINTS,
            "Exceeded the limit"
        );
        require(
            totalSupply() + quantity <= MAX_SUPPLY,
            "Not enough tokens left"
        );
        _safeMint(msg.sender, quantity);
    }

    function giveawaymint(address _giveawayAddress, uint256 quantity)
        public
        onlyOwner
    {
        require(
            totalSupply() + quantity <= MAX_SUPPLY,
            "Not enough tokens left"
        );
        _safeMint(_giveawayAddress, quantity);
    }

    function isValidMerkleProof(bytes32[] calldata merkleProof, bytes32 root)
        public
        view
    {
        require(
            MerkleProof.verify(
                merkleProof,
                root,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Address does not exist in list"
        );
        
    }

    function isCorrectPayment(
        uint256 price,
        uint256 numberOfTokens,
        uint256 _value
    ) public pure {
        require(price * numberOfTokens == _value, "Incorrect ETH value sent");
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: Nonexistent token");
        string memory currentBaseURI = baseURI;
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        extension
                    )
                )
                : "";
    }

    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setwhiteListRate(uint256 _whiteListRate) public onlyOwner {
        whiteListRate = _whiteListRate;
    }

    function setMintRate(uint256 _mintRate) public onlyOwner {
        mintRate = _mintRate;
    }

    function flipSale(bool _iswhiteListSale) public onlyOwner {
        iswhiteListSale = _iswhiteListSale;
    }

    function setBaseExtension(string memory _newbaseURI) public onlyOwner {
        baseURI = _newbaseURI;
    }

    function setmaxMintAmount(uint256 _MAX_MINTS) public onlyOwner {
        MAX_MINTS = _MAX_MINTS;
    }
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

}
