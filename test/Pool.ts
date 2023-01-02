import { expect } from "chai";
import { ethers } from "hardhat";

const TOKEN_KINDS = {
  ERC20: ethers.BigNumber.from("0"),
  ERC721: ethers.BigNumber.from("1"),
  ERC1155: ethers.BigNumber.from("2"),
  ETH: ethers.BigNumber.from("3"),
};

describe("Pool", function () {
  const initContracts = async () => {
    const [owner, account1, account2] = await ethers.getSigners();

    const Pool = await ethers.getContractFactory("Pool");
    const pool = await Pool.deploy();

    const ERC20 = await ethers.getContractFactory("TestERC20");
    const erc20 = await ERC20.deploy();
    erc20.mint(account1.address, 10);

    const ERC721 = await ethers.getContractFactory("TestERC721");
    const erc721 = await ERC721.deploy();
    erc721.mint(account1.address, 1);

    const ERC1155 = await ethers.getContractFactory("TestERC1155");
    const erc1155 = await ERC1155.deploy();
    erc1155.mint(account1.address, 1, 10);

    return { pool, erc20, erc721, erc1155, owner, account1, account2 };
  };

  describe("ERC20 deposit & withdrawal", () => {
    it("should deposit & withdraw tokens", async () => {
      const { pool, erc20, account1, account2 } = await initContracts();

      await erc20.connect(account1).approve(pool.address, 5);

      await expect(
        pool
          .connect(account1)
          .deposit(TOKEN_KINDS.ERC20, erc20.address, account2.address, 0, 5)
      ).to.changeTokenBalances(erc20, [account1, pool], [-5, 5]);

      await expect(pool.connect(account2).withdraw(0)).to.changeTokenBalances(
        erc20,
        [account2, pool],
        [5, -5]
      );
    });
  });

  describe("ERC721 deposit & withdrawal", () => {
    it("should deposit & withdraw tokens", async () => {
      const { pool, erc721, account1, account2 } = await initContracts();

      await erc721.connect(account1).approve(pool.address, 1);

      await expect(
        pool
          .connect(account1)
          .deposit(TOKEN_KINDS.ERC721, erc721.address, account2.address, 1, 1)
      ).to.changeTokenBalances(erc721, [account1, pool], [-1, 1]);

      await expect(pool.connect(account2).withdraw(0)).to.changeTokenBalances(
        erc721,
        [account2, pool],
        [1, -1]
      );
    });
  });

  describe("ERC1155 deposit & withdrawal", () => {
    it("should deposit & withdraw tokens", async () => {
      const { pool, erc1155, account1, account2 } = await initContracts();

      await erc1155.connect(account1).setApprovalForAll(pool.address, true);

      await pool
        .connect(account1)
        .deposit(TOKEN_KINDS.ERC1155, erc1155.address, account2.address, 1, 5);

      const bp1 = await erc1155.balanceOf(pool.address, 1);
      const b1 = await erc1155.balanceOf(account1.address, 1);
      expect(bp1.toNumber()).to.equal(5);
      expect(b1.toNumber()).to.equal(5);

      await pool.connect(account2).withdraw(0);

      const bp2 = await erc1155.balanceOf(pool.address, 1);
      const b2 = await erc1155.balanceOf(account2.address, 1);
      expect(bp2.toNumber()).to.equal(0);
      expect(b2.toNumber()).to.equal(5);
    });
  });

  describe("ETH deposit & withdrawal", () => {
    it("should deposit & withdraw tokens", async () => {
      const { pool, account1, account2 } = await initContracts();

      await expect(
        pool
          .connect(account1)
          .deposit(
            TOKEN_KINDS.ETH,
            ethers.constants.AddressZero,
            account2.address,
            0,
            5,
            { value: 5 }
          )
      ).to.changeEtherBalances([account1, pool], [-5, 5]);

      await expect(pool.connect(account2).withdraw(0)).to.changeEtherBalances(
        [account2, pool],
        [5, -5]
      );
    });
  });
});
