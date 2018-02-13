import ether from "./helpers/ether";
import { advanceBlock } from "./helpers/advanceToBlock";
import increaseTime, { increaseTimeTo, duration } from "./helpers/increaseTime";
import latestTime from "./helpers/latestTime";
import EVMThrow from "./helpers/EVMThrow";
import { capture, restore, Snapshot } from "./helpers/snapshot";
import timer from "./helpers/timer";
import sendTransaction from "./helpers/sendTransaction";
import "./helpers/upgradeBigNumber";

const moment = require("moment");

const BigNumber = web3.BigNumber;
const eth = web3.eth;

const should = require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

const InsecureAuction = artifacts.require("./InsecureAuction.sol");
const InsecureAuctionAttack = artifacts.require("./InsecureAuctionAttack.sol");

contract("InsecureAuctionAttack", async ([ auctionOwner, attackOwner, other, ...accounts ]) => {
  let auction, attacker;

  const snapshot = new Snapshot();

  before(snapshot.captureContracts);
  after(snapshot.restoreContracts);

  before(async () => {
    auction = await InsecureAuction.new();
    attacker = await InsecureAuctionAttack.new(auction.address, { from: attackOwner });
  });

  it("first bid should be accepted", async () => {
    await attacker.bid({ value: 1 })
      .should.be.fulfilled;
  });

  it("no one can bid even with higher value", async () => {
    await auction.bid({ from: other, value: ether(2) })
      .should.be.rejectedWith(EVMThrow);
  });
});
