let MintOrigin = artifacts.require("MintOrigin");

contract("MintOrigin", function (accounts) {
  const price = 1000000000;
  const owner = accounts[0];
  const child1 = accounts[1];
  const child2 = accounts[2];
  const Minter1 = accounts[3];
  const Minter2 = accounts[4];
  const Distributor1 = accounts[5];
  const Distributor2 = accounts[6];
  const newChild = accounts[7];
  const newOwner = accounts[8];
  const newMinter = accounts[9];

  it("Set contract ", async function () {
    this.MintOrigin = await MintOrigin.new(child1, child2, { from: owner });
  });

  it("Set child 1", async function () {
    expect(await this.MintOrigin.child1()).to.be.equal(child1);
  });

  it("Set child 2", async function () {
    expect(await this.MintOrigin.child2()).to.be.equal(child2);
  });

  it("Set owner", async function () {
    expect(await this.MintOrigin.owner()).to.be.equal(owner);
  });

  it("Set minter 1", async function () {
    await this.MintOrigin.setMinter(Minter1, "Bianchi");
    const MintInfo = await this.MintOrigin.MintInfo(Minter1);
    expect(MintInfo.Name).to.be.equal("Bianchi");
  });

  it("Set minter 2", async function () {
    await this.MintOrigin.setMinter(Minter2, "Pinarello");
    const MintInfo = await this.MintOrigin.MintInfo(Minter2);
    expect(MintInfo.Name).to.be.equal("Pinarello");
  });

  it("Create new distributor", async function () {
    await this.MintOrigin.createDist(Distributor1, "Robeet", { from: Minter1 });
    const DistInfo = await this.MintOrigin.DistInfo(Distributor1);
    expect(DistInfo.Name).to.be.equal("Robeet");
  });

  it("Add new distributor", async function () {
    await this.MintOrigin.addDist(Distributor1, { from: Minter2 });
    const DistInfo = await this.MintOrigin.viewDist(0, Minter2);
    expect(DistInfo).to.be.equal(Distributor1);
  });

  it("Create directly to minter", async function () {
    await this.MintOrigin.create(Minter1, 100, "Sempre", { from: Minter1 });
    expect(await this.MintOrigin.ownerOf(100)).to.be.equal(Minter1);
  });

  it("Create directly to distributor", async function () {
    await this.MintOrigin.create(Distributor1, 200, "Dogma", { from: Minter2 });
    expect(await this.MintOrigin.ownerOf(200)).to.be.equal(Distributor1);
  });

  it("Complete check up", async function () {
    await this.MintOrigin.checkToken(200, { from: Distributor1 });
    expect(await this.MintOrigin.ownerOf(200)).to.be.equal(Distributor1);
  });

  it("Change child", async function () {
    await this.MintOrigin.proposeChangeChild(child1, newChild, { from: owner });
    await this.MintOrigin.changeChild(newChild, { from: child2 });
    expect(await this.MintOrigin.child1()).to.be.equal(newChild);
  });

  it("Change owner", async function () {
    await this.MintOrigin.changeParent(newOwner, { from: newChild });
    await this.MintOrigin.changeParent(newOwner, { from: child2 });
    expect(await this.MintOrigin.owner()).to.be.equal(newOwner);
  });

  it("Change manufacturer", async function () {
    await this.MintOrigin.changeManufacturer(Minter1, newMinter, {
      from: newOwner,
    });
    const MintInfo = await this.MintOrigin.MintInfo(newMinter);
    expect(MintInfo.Name).to.be.equal("Bianchi");
  });
});
