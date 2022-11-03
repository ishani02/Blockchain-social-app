const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BytesLike } = require("ethers");
const { AbiCoder } = require("@ethersproject/abi");

describe.only("Social App", async () => {
  let contract;
  const abiCoder = new AbiCoder();
  const MOCK_PROFILE_URI =
    "https://ipfs.io/ipfs/Qme7ss3ARVgxv6rXqVPiikMJ8u2NLgmgszg13pYrDKEoiu";
  const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
  const MOCK_FOLLOW_NFT_URI =
    "https://ipfs.fleek.co/ipfs/ghostplantghostplantghostplantghostplantghostplantghostplan";
  const MOCK_PROFILE_HANDLE = "plant1ghost.eth";
  const FIRST_PROFILE_ID = 1;
  const DEFAULT_FOLLOW_DATA = BytesLike;
  const MOCK_URI =
    "https://ipfs.io/ipfs/QmbWqxBEKC3P8tqsKc98xmWNzrzDtRLMiMPL8wBuTGsMnR";

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    owner = await accounts[0];
    getFollowModule = await ethers.getContractFactory("Follow");
    getInteractionLogic = await ethers.getContractFactory(
      "libraries/InteractionLogic.sol:InteractionLogic"
    );
    getPublishingLogic = await ethers.getContractFactory(
      "libraries/PublishingLogic.sol:PublishingLogic"
    );
    interactionContract = await getInteractionLogic.deploy();
    publishingContract = await getPublishingLogic.deploy();

    getHubContract = await ethers.getContractFactory("Hub", {
      libraries: {
        InteractionLogic: interactionContract.address,
        PublishingLogic: publishingContract.address,
      },
    });

    contract = await getHubContract.deploy();
    followModule = await getFollowModule.deploy(contract.address);
  });
  describe("Social App test cases", async () => {
    it("profile cannot be created if user is not whitelisted", async () => {
      const val = "11111111111111111111111111111111";
      expect(val.length).to.eq(32);
      await expect(
        contract.createProfile({
          to: accounts[1].address,
          handle: MOCK_PROFILE_HANDLE,
          imageURI: MOCK_PROFILE_URI,
          followModule: ZERO_ADDRESS,
          followModuleInitData: [],
          followNFTURI: MOCK_FOLLOW_NFT_URI,
        })
      ).to.be.revertedWith("ProfileCreatorNotWhitelisted()");
    });
    it("create profile", async () => {
      await contract.whitelistProfileCreator(accounts[1].address, true);
      await expect(
        contract.connect(accounts[1]).createProfile({
          to: accounts[1].address,
          handle: "token.id_1",
          imageURI: MOCK_PROFILE_URI,
          followModule: ZERO_ADDRESS,
          followModuleInitData: [],
          followNFTURI: MOCK_FOLLOW_NFT_URI,
        })
      ).to.not.be.reverted;
    });

    it("follow a user", async () => {
      await contract.whitelistProfileCreator(accounts[1].address, true);
      await contract.connect(accounts[1]).createProfile({
        to: accounts[1].address,
        handle: "token.id_1",
        imageURI: MOCK_PROFILE_URI,
        followModule: ZERO_ADDRESS,
        followModuleInitData: [],
        followNFTURI: MOCK_FOLLOW_NFT_URI,
      });
      await expect(
        contract
          .connect(accounts[2])
          .follow([FIRST_PROFILE_ID], [DEFAULT_FOLLOW_DATA])
      ).to.not.be.reverted;
    });

    it("create a post", async () => {
      await contract.whitelistProfileCreator(accounts[1].address, true);
      await contract.connect(accounts[1]).createProfile({
        to: accounts[1].address,
        handle: "token.id_1",
        imageURI: MOCK_PROFILE_URI,
        followModule: ZERO_ADDRESS,
        followModuleInitData: [],
        followNFTURI: MOCK_FOLLOW_NFT_URI,
      });

      await expect(
        contract.post({
          profileId: FIRST_PROFILE_ID,
          contentURI: MOCK_URI,
          collectModule: followModule.address,
          collectModuleInitData: abiCoder.encode(["bool"], [true]),
          referenceModule: ZERO_ADDRESS,
          referenceModuleInitData: [],
        })
      );
    });
  });
});
