pragma solidity ^0.6.2;

import "./OpenZeppelin/contracts/token/ERC721/ERC721.sol";
import "./OpenZeppelin/contracts/utils/EnumerableSet.sol";

contract MintOrigin is ERC721 {
    using EnumerableSet for EnumerableSet.AddressSet;
    address payable public owner;
    address public child1;
    address public child2;
    // For changing the  manufacturer

    address public cParent;
    address public removeSig;

    address public oldChild;
    address public newChild;

    EnumerableSet.AddressSet Minters;

    //Add Location
    struct minter {
        string Name;
        uint256 Time;
    }

    struct distributor {
        string Name;
        uint256 Time;
        bool isDist;
    }

    struct product {
        string Name;
        address Creator;
        uint256 Time;
    }

    mapping(uint256 => product) public Product;
    mapping(address => minter) public MintInfo;
    mapping(address => EnumerableSet.AddressSet) Distributors;

    //change to array
    mapping(address => EnumerableSet.AddressSet) DistMinters;
    mapping(address => distributor) public DistInfo;

    event checkUp(
        uint256 indexed _tokenId,
        address indexed _dist,
        address indexed _owner,
        uint256 _time
    );

    constructor(address _child1, address _child2)
        public
        ERC721("MintOrigin", "DemoCoin")
    {
        owner = msg.sender;
        cParent = address(0);
        child1 = _child1;
        child2 = _child2;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier onlyChild(address _add) {
        require(
            _add == child1 || _add == child2,
            "You are not the child of the owner"
        );

        _;
    }

    modifier onlyManufacturer {
        require(
            Minters.contains(msg.sender),
            "You need to be a registered manufacturer to complete this action"
        );
        _;
    }

    modifier existingManufacturer(address _to) {
        require(
            Minters.contains(_to) == true,
            "The manufacturer does not exist"
        );
        _;
    }

    modifier nonZeroAddress(address _to) {
        require(_to != address(0), "zero address was provided");
        _;
    }

    modifier theSameAddress(address _1, address _2) {
        require(_1 == _2, "The provided valued are different");
        _;
    }

    modifier theSameBool(bool _1, bool _2) {
        require(_1 == _2, "The values are different");
        _;
    }

    function setMinter(address _to, string memory _name)
        public
        theSameBool(Minters.contains(_to), false)
        onlyOwner
    {
        Minters.add(_to);
        MintInfo[_to] = minter(_name, now);
    }

    function proposeChangeChild(address _old, address _new)
        public
        onlyOwner
        onlyChild(_old)
    {
        oldChild = _old;
        newChild = _new;
    }

    function changeChild(address _new)
        public
        onlyChild(msg.sender)
        theSameAddress(_new, newChild)
    {
        if (child1 == oldChild) {
            child1 = _new;
        } else {
            child2 = _new;
        }
    }

    function changeParent(address payable _new) public onlyChild(msg.sender) {
        //Require that they are different
        if (cParent == address(0)) {
            removeSig = msg.sender;
            cParent = _new;
        } else {
            require(
                msg.sender != removeSig,
                "You have already voted on the proposal"
            );
            require(
                _new == cParent,
                "You and the other child account have put forward differing proposals"
            );
            owner = _new;
            cParent = address(0);
        }
    }

    /**function proposeChangeManufacturer(address _to, address _new) public onlyOwner existingManufacturer(_to) {
        oldMan = _to;
        newMan = _new;
    }**/

    function changeManufacturer(address _old, address _new)
        public
        onlyOwner
        existingManufacturer(_old)
        nonZeroAddress(_new)
    {
        MintInfo[_new] = MintInfo[_old];
        Distributors[_new] = Distributors[_old];
        Minters.remove(_old);
        Minters.add(_new);
    }

    /**function proposeRemoveMinter(address _to) public onlyOwner existingManufacturer(_to){


        removeMan = _to; 
    } **/

    function removeMinter(address _old)
        public
        onlyOwner
        existingManufacturer(_old)
    {
        Minters.remove(_old);
    }

    function getMinters() public view returns (uint256) {
        return Minters.length();
    }

    function getMinter(uint256 _id) public view returns (address) {
        return Minters.at(_id);
    }

    function create(
        address payable _to,
        uint256 _tokenId,
        string memory _assetName
    ) public payable onlyManufacturer {
        Product[_tokenId] = product(_assetName, msg.sender, now);
        _safeMint(_to, _tokenId);
        owner.transfer(msg.value);
    }

    /** Test that you arent overriding anything **/
    function addDist(address _to)
        public
        onlyManufacturer
        theSameBool(DistInfo[_to].isDist, true)
        theSameBool(Distributors[msg.sender].contains(_to), false)
    {
        //require that they exist

        /**  require(
            DistInfo[_to].isDist == true,
            "This distributor does not exist yet, you must use the createDist function"
        );
        require(
            Distributors[msg.sender].contains(_to) == false,
            "This is already one of your distributors"
        ); 
        **/
        Distributors[msg.sender].add(_to);
        DistMinters[_to].add(msg.sender);
    }

    //Only removes this dist for you
    function removeDist(address _to) public onlyManufacturer {
        Distributors[msg.sender].remove(_to);
        DistMinters[_to].remove(msg.sender);
    }

    function viewDists(address _minter) public view returns (uint256) {
        return Distributors[_minter].length();
    }

    //Give everyone access to viewing distributors
    function viewDist(uint256 _pos, address _minter)
        public
        view
        returns (address)
    {
        return Distributors[_minter].at(_pos);
    }

    // add an event for the minting of  token
    function checkToken(uint256 _tokenId)
        public
        theSameBool(
            Distributors[Product[_tokenId].Creator].contains(msg.sender),
            true
        )
    {
        //Backing that the bike is in good conndition
        // Check that the person doing the checking is a distributor of the product minter
        //    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

        address o = ownerOf(_tokenId);

        emit checkUp(_tokenId, msg.sender, o, now);
    }

    function viewDMinters(address _to) public view returns (address[] memory) {
        uint256 length = DistMinters[_to].length();
        address[] memory minters = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            minters[i] = DistMinters[_to].at(i);
        }
        return minters;
    }

    function createDist(address _to, string memory _name)
        public
        onlyManufacturer
        theSameBool(DistInfo[_to].isDist, false)
    {
        DistInfo[_to] = distributor(_name, now, true);
        DistMinters[_to].add(msg.sender);
        Distributors[msg.sender].add(_to);
    }

    function sendValueToken(
        address payable _to,
        uint256 _tokenId,
        string memory _name
    ) public payable {
        //First call the transfer function to make sure this passes before value is sendValueToken
        safeTransferFrom(msg.sender, _to, _tokenId);
        _to.transfer(msg.value);
        Product[_tokenId].Name = _name;
    }
}
