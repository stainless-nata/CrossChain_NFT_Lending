import React, { useState } from "react";
import nftData from "../utils/data";
import { AiFillCloseCircle } from "react-icons/ai";

const TakeLoan = () => {
  const [selectedNft, setSelectedNft] = useState(null);

  const openPopup = (nft) => {
    setSelectedNft(nft);
  };

  const closePopup = () => {
    setSelectedNft(null);
  };

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
              <button
                className="bg-primaryColor text-backgroundColor font-semibold py-3 rounded-xl mt-6 w-full"
                onClick={() => openPopup(nft)}
              >
                Deposit NFT
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Pop-up/Modal */}
      {selectedNft && (
        <div className="fixed h-screen inset-0 flex items-center justify-center bg-black bg-opacity-50">
          <div className="bg-white md:p-8 p-4 rounded-lg m-8 md:m-0 md:w-1/2 ">
            <div className=" flex items-end justify-end">
              <AiFillCloseCircle
                className=" text-xl mb-4 md:text-3xl md:mb-6 text-gray-600 cursor-pointer"
                onClick={closePopup}
              />
            </div>
            <div className="flex items-center justify-center flex-col">
              <img
                src={selectedNft.imageSrc}
                alt={selectedNft.title}
                className="rounded-lg"
              />

              <p className="font-semibold text-lg text-backgroundColor mt-3">
                {selectedNft.title}
              </p>
              <p className="text-subtitleColor text-justify mt-3">
                {selectedNft.description}
              </p>
              <button className=" text-backgroundColor font-semibold bg-primaryColor w-full rounded-lg py-3 mt-5">
                DUSD AMOUNT
              </button>
            </div>
          </div>

          {/* <div className=" flex items-center justify-center">
            <img
              src={selectedNft.imageSrc}
              alt={selectedNft.title}
              className=" rounded-lg w-2/4"
            />
          </div> */}
        </div>
      )}
    </div>
  );
};

export default TakeLoan;
