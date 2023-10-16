import React from "react";
import nftData from "../utils/data";

const TakeLoan = () => {
  return (
    <div>
      <p className=" text-[2rem] md:text-[3rem] md:mt-10 font-semibold mb-4 md:mb-8 ">
        Avaiable NFT's
      </p>
      <div className=" grid md:grid-cols-3 lg:grid-cols-4 grid-cols-1 mt-5 md:mt-0 gap-10">
        {nftData.map((nft, index) => (
          <div className="bg-cardBg flex flex-col rounded-lg pb-4" key={index}>
            <img src={nft.imageSrc} alt={nft.title} className=" rounded-t-lg" />
            <div className="p-4">
              <p className="font-semibold text-xl">{nft.title}</p>
              <p className="text-subtitleColor text-justify mt-3">
                {nft.description}
              </p>
              <button className="bg-primaryColor text-backgroundColor font-semibold py-3 rounded-xl mt-6 w-full">
                Deposit NFT
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default TakeLoan;
