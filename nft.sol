// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0; 

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./_ERC20.sol";
import "./ancientnft.sol";
import "./babynft.sol";
import "./nftInterface.sol";
import "./erc20interface.sol"; 


contract ERC721  is Context, ERC165, IERC721, IERC721Metadata, Ownable, IERC721Enumerable {
    using Address for address;
    using Strings for uint256;
    using Counters for Counters.Counter; 

    
   

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // uint public totalSupply;

    Counters.Counter private _tokenIds;
    
    

    string public baseURI_ = "ipfs://QmeWdrqHA32zQRjU9oKmsi6NDGdv1dpnyxRi3pcm27Dkqb/";
    string public baseExtension = ".json";
    uint256 public cost = 0.03 ether;
    uint256 public maxSupply = 3333;
    uint256 public maxMintAmount = 10;
    bool public paused = false;
    bool public  _paused ;
   
     

     // wallet addresses for claims
    address private constant possumchsr69 = 0x31FbcD30AA07FBbeA5DB938cD534D1dA79E34985;
    address private constant Jazzasaurus =
        0xd848353706E5a26BAa6DD20265EDDe1e7047d9ba;
    address private constant munheezy = 0xB6D2ac64BDc24f76417b95b410ACf47cE31AdD07;
    address private constant _community =
        0xe44CB360e48dA69fe75a78fD1649ccbd3CCf7AD1;
    
    mapping(uint => mapping(address => uint)) private idtostartingtimet;

        
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

     mapping(address => mapping(uint256 => bool)) private _breeded;

     ERC20 _ERC20;
     ancientnft _ancientnft;  
     babynft _babynft; 

     IERC20_ iERC20_;
     _IERC721 mainERC721;
     _IERC721 ancientERC721;
     _IERC721 babyERC721;
     bool hassetcuurent;   

      




    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;


   
    constructor(string memory name_, string memory symbol_,string memory ERC20name_, string memory ERC20symbol_ ,uint ERC20amount,address ERC20owneraddress,string memory ancientnftname_, string memory ancientnftsymbol_,string memory babynftname_, string memory babynftsymbol_) {
        _name = name_;
        _symbol = symbol_;
       
        _ERC20= new ERC20(ERC20name_,ERC20symbol_,ERC20amount,ERC20owneraddress) ;
        
        _ancientnft = new ancientnft(ancientnftname_,ancientnftsymbol_);
        _ancientnft.setapprovedcontractaddress(address(this));
        _ancientnft.seterc20address(address(_ERC20));
        _babynft= new  babynft(babynftname_,babynftsymbol_);
        _babynft.setapprovedcontractaddress(address(this));
        _babynft.seterc20address(address(_ERC20)); 
        _ERC20.setapprovedcontractaddress(address(this),address(_ancientnft),address(_babynft));

    }

   
    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function pause() public onlyOwner  {
        paused = !paused;

     }

      function pausebreedandburn() public onlyOwner  {
        _paused = !_paused;

     }

    function checkPause() public view onlyOwner returns(bool) {
        return paused; 
    }
 
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual  {
     

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

   
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

   
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

  
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

   
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

  
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

  
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }


    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

   
    function name() public view virtual override returns (string memory) {
        return _name;
    }

   
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

  
    function _baseURI() internal view virtual returns (string memory) {
        return baseURI_;
    }

   
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

   
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

  
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }


    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

  
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

   
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

   
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }


    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

   
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }


    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;
        idtostartingtimet[tokenId][to]=block.timestamp;

        // totalSupply+=1;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

  

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];
        

        // totalSupply-=1;

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }
     
     function mint(
        address _to,
        uint256 _mintAmount
        
    ) public payable {
        // get total NFT token supply
      
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require( totalSupply() + _mintAmount <= maxSupply);
        require(paused == false);
        require (hassetcuurent==true,"please set setcurrentmintedamount ");
            
        
        require(msg.value >= cost * _mintAmount);
            
        

    

        // execute mint
       if (_tokenIds.current()==0){
            _tokenIds.increment();
       }
        
        for (uint256 i = 1; i <= _mintAmount; i++) {
            uint256 newTokenID = _tokenIds.current();
            _safeMint(_to, newTokenID);
            _tokenIds.increment();
        }
    }

    function setcurrentmintedamount(uint totalmintedamount )public onlyOwner{
           hassetcuurent=true;
            if (_tokenIds.current()==0){
            _tokenIds.increment();
       }

       for (uint256 i = 1; i <=totalmintedamount; i++) {
          
            _tokenIds.increment();
         
        }
    }

    function checkdragonnotbreeded(address add)public view returns(uint[] memory){

        uint256 ownerTokenCount = balanceOf(add);
           uint256[] memory tokenIds = new uint256[](ownerTokenCount);
         tokenIds= walletofNFT(add);  
         
         
          uint count;
         for (uint i ;i<ownerTokenCount; i++){
             if (_breeded[address(this)][tokenIds[i]]==false){
                count++;   
             }
            
          
           }
          uint256[] memory notbreededbrtokenIds = new uint256[](count);
          uint _count;
            for (uint i ;i<ownerTokenCount; i++){
             if (_breeded[address(this)][tokenIds[i]]==false){
                   notbreededbrtokenIds[_count]=tokenIds[i];
                   _count++;
             }
            
          
           }

           return notbreededbrtokenIds;
        }
    
    

   
    function breed(uint id1,uint id2) public  {
        uint amount=1800*10**18;
        require(balanceOf(msg.sender)>=2, "Must Own 2 0xDragons");
        require (_ERC20.balanceOf(msg.sender) >= amount,"You Dont Have The $SCALE For That!");
        require (ownerOf(id1)==msg.sender,"NOT YOUR DRAGON");
        require (ownerOf(id2)==msg.sender,"NOT YOUR DRAGON");
        require( _paused == true);
        _ERC20.burn(msg.sender, amount);

       
         _breeded[address(this)][id1]=true;
           _breeded[address(this)][id2]=true;
            

        _babynft.mint(msg.sender);  
    }

    
    function burn(uint id1, uint id2, uint id3 ) public  {
    uint amount=1500*10**18;
    require(balanceOf(msg.sender)>=3, "Must Have 3 UNBRED Dragons");
    require (_ERC20.balanceOf(msg.sender) >= amount,"You Dont Have The $SCALE For That!");
    require (ownerOf(id1)==msg.sender,"NOT YOUR DRAGON");
    require (ownerOf(id2)==msg.sender,"NOT YOUR DRAGON");
    require (ownerOf(id3)==msg.sender,"NOT YOUR DRAGON"); 
    require( _breeded[address(this)][id1]==false ,"Bred Dragons CAN'T Be Sacrificed");
    require( _breeded[address(this)][id2]==false ,"Bred Dragons CAN'T Be Sacrificed"); 
    require( _breeded[address(this)][id3]==false ,"Bred Dragons CAN'T Be Sacrificed");
    require( _paused == true);
    _ERC20.burn(msg.sender, amount);

  _transfer(
      msg.sender,
      0x000000000000000000000000000000000000dEaD,
      id1
);
_transfer(
      msg.sender,
      0x000000000000000000000000000000000000dEaD,
      id2
);
_transfer(
      msg.sender,
      0x000000000000000000000000000000000000dEaD,
      id3
);   
         
      _ancientnft.mint(msg.sender);   
        
        
     }

   function setpreviouscontaddress(address erc20add,address mainnftadd ,address ancientadd, address babyadd )public onlyOwner{
       
     iERC20_=IERC20_(erc20add) ;
     mainERC721 =  _IERC721(mainnftadd);
     ancientERC721= _IERC721(ancientadd);
     babyERC721=_IERC721(babyadd);



   }


   function setmaxsupplyforbabynft(uint amount)public onlyOwner{
        _babynft.setmaxsupply(amount);

   }

   function setbaseuriforbabynft(string memory _newBaseURI) public onlyOwner{
       _babynft.setBaseURI(_newBaseURI);
   }

   
   function setcurrentmintnumberforbabynft(uint amount) public onlyOwner{
       _babynft.setcurrentmintedamount(amount );   
   }

   
   function setbaseuriforancientnft(string memory _newBaseURI) public onlyOwner{
       _ancientnft.setBaseURI(_newBaseURI);
   }

    function setcurrentmintnumberforancient(uint amount) public onlyOwner{
        _ancientnft.setcurrentmintedamount(amount ); 
   }


    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    // set or update max number of mint per mint call
    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

   

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI_ = _newBaseURI;
    }

    // set metadata base extention
    function setBaseExtension(string memory _newBaseExtension)public onlyOwner    {
        baseExtension = _newBaseExtension;    }


    

    function claim() public onlyOwner {
        // get contract total balance
        uint256 balance = address(this).balance;
        // begin withdraw based on address percentage

        // 40%
        payable(Jazzasaurus).transfer((balance / 100) * 40);
        // 20%
        payable(possumchsr69).transfer((balance / 100) * 20);
        // 25%
        payable(munheezy).transfer((balance / 100) * 25);
        // 15%
        payable(_community).transfer((balance / 100) * 15);
    }

      function walletofNFT(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function checkrewardbal()public view returns(uint){

        uint256 ownerTokenCount = balanceOf(msg.sender);
           uint256[] memory tokenIds = new uint256[](ownerTokenCount);
         tokenIds= walletofNFT(msg.sender);
         
          uint current;
          uint reward;
          uint rewardbal;
         for (uint i ;i<ownerTokenCount; i++){
             
             if (idtostartingtimet[tokenIds[i]][msg.sender]>0 ){
           current = block.timestamp - idtostartingtimet[tokenIds[i]][msg.sender];
             reward = ((10*10**18)*current)/86400;
            rewardbal+=reward;
          
           }
        }

        return rewardbal;
    }

    function checkrewardforancientbal()public view returns(uint){
      return _ancientnft.checkrewardbal(msg.sender);
    }

    function checkrewardforbabybal()public view returns(uint){
      return _babynft.checkrewardbal(msg.sender);
    }

    function claimreward() public {
          require(balanceOf(msg.sender)>0, "Not Qualified For Reward");
         uint256 ownerTokenCount = balanceOf(msg.sender);
           uint256[] memory tokenIds = new uint256[](ownerTokenCount);
         tokenIds= walletofNFT(msg.sender);
         
          uint current;
          uint reward;
          uint rewardbal;
         for (uint i ;i<ownerTokenCount; i++){
             
             if (idtostartingtimet[tokenIds[i]][msg.sender]>0 ){
           current = block.timestamp - idtostartingtimet[tokenIds[i]][msg.sender];
             reward = ((10*10**18)*current)/86400;
            rewardbal+=reward;
          idtostartingtimet[tokenIds[i]][msg.sender]=block.timestamp;
           }
        }

         _ERC20.mint(msg.sender,rewardbal);
     if (_ancientnft.balanceOf(msg.sender)>0){
        _ancientnft.claimreward(msg.sender);

        }
    if (_babynft.balanceOf(msg.sender)>0){
        _babynft.claimreward(msg.sender);
        }


    }


        
    

    function migrate()public   {
          uint[] memory _tokenId= mainERC721.walletofNFT(msg.sender);
        //   uint[] memory notbreeded= mainERC721.checkdragonnotbreeded(msg.sender);  
          for (uint i ;i< _tokenId.length;i++){
              require(msg.sender==mainERC721.ownerOf(_tokenId[i]));

            mainERC721.transferFrom(msg.sender,0x000000000000000000000000000000000000dEaD,_tokenId[i]);  
            _mint(msg.sender,_tokenId[i] );
            //    _breeded[address(this)][i]=true; 
            //   for(uint j;j<notbreeded.length;j++){ 
            //       if(_tokenId[i]== notbreeded[j]){
            //         _breeded[address(this)][i]=false; 
            //       }    
          } 
          
           uint[] memory _tokenId1=  ancientERC721.walletofNFT(msg.sender);   
          for (uint i ;i< _tokenId1.length;i++){
              require(msg.sender== ancientERC721.ownerOf(_tokenId1[i]));
               ancientERC721.transferFrom(msg.sender,0x000000000000000000000000000000000000dEaD,_tokenId1[i]);
               _ancientnft.mint(msg.sender,_tokenId1[i] ); 

          } 

           uint[] memory _tokenId2= babyERC721.walletofNFT(msg.sender);   
          for (uint i ;i< _tokenId2.length;i++){
              require(msg.sender==babyERC721.ownerOf(_tokenId2[i]));
              babyERC721.transferFrom(msg.sender,0x000000000000000000000000000000000000dEaD,_tokenId2[i]);
              _babynft.mint(msg.sender,_tokenId2[i] ); 
          }   
 
          uint amount= iERC20_.balanceOf(msg.sender);
          uint mainnftamount= mainERC721.checkrewardbal();
          uint ancientnftamount= ancientERC721.checkrewardbal(msg.sender);
          uint babynftamount= babyERC721.checkrewardbal(msg.sender);
          uint totalamount=amount+ mainnftamount + ancientnftamount + babynftamount;
          iERC20_.transferFrom(msg.sender,0x000000000000000000000000000000000000dEaD, amount);
          _ERC20.mint(msg.sender,totalamount);
        
    } 

   

     function migrate2(uint[] memory main,uint[] memory ancient,uint[] memory baby)public   {
          uint[] memory _tokenId=  main;    
          for (uint i ;i< _tokenId.length;i++){
              require(msg.sender==mainERC721.ownerOf(_tokenId[i]));
              mainERC721.transferFrom(msg.sender,0x000000000000000000000000000000000000dEaD,_tokenId[i]); 
              _mint(msg.sender,_tokenId[i] ); 
          } 
           uint[] memory _tokenId1=  ancient;  
          for (uint i ;i< _tokenId1.length;i++){
              require(msg.sender== ancientERC721.ownerOf(_tokenId1[i]));
               ancientERC721.transferFrom(msg.sender,0x000000000000000000000000000000000000dEaD,_tokenId1[i]);
               _ancientnft.mint(msg.sender,_tokenId1[i] ); 

          } 

           uint[] memory _tokenId2= baby;    
          for (uint i ;i< _tokenId2.length;i++){
              require(msg.sender==babyERC721.ownerOf(_tokenId2[i]));
              babyERC721.transferFrom(msg.sender,0x000000000000000000000000000000000000dEaD,_tokenId2[i]);
              _babynft.mint(msg.sender,_tokenId2[i] ); 
          }   
 
          uint amount= iERC20_.balanceOf(msg.sender);
        //   uint mainnftamount= mainERC721.checkrewardbal();
          uint ancientnftamount= ancientERC721.checkrewardbal(msg.sender);
          uint babynftamount= babyERC721.checkrewardbal(msg.sender);
          uint totalamount=amount + ancientnftamount + babynftamount; 
          iERC20_.transferFrom(msg.sender,0x000000000000000000000000000000000000dEaD, amount);
          _ERC20.mint(msg.sender,totalamount);
        
    } 


     function checkerc20address()public view returns(address) {

     return  (address(_ERC20)); //  this is the deployed address of erc20token
     
 }

    
     function checkancientnftaddress()public view returns(address) {

     return  (address(_ancientnft)); //  this is the deployed address of ancienttoken
     
    }

    
     function checkbabynftaddress()public view returns(address) {

     return  (address(_babynft)); //  this is the deployed address of babytoken
     
 }





    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        idtostartingtimet[tokenId][to]=block.timestamp;
        idtostartingtimet[tokenId][from]=0;
        

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

   
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

  
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }


  
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}