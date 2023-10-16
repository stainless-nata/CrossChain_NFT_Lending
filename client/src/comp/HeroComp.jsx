import React from "react";
import heroAnimation from "../img/heroAnimation.json";
import Lottie from "lottie-react";

const HeroComp = () => {
  return (
    <div class="md:grid md:grid-flow-col md:gap-16 md:mt-28 justify-center">
      <div class="md:hidden flex col-span-2 text-center md:text-left mt-6 md:mt-0 text-[3.5rem] md:text-[9.5rem] font-extrabold leading-tight">
        Start Making Money With NFT's
      </div>

      <div class="row-span-3 flex flex-col">
        <Lottie animationData={heroAnimation} />

        <p className=" text-subtitleColor md:pl-10 text-center md:text-left">
          Lorem ipsum dolor sit amet consectetur adipisicing elit. Similique ex
          accusantium facilis a ducimus
        </p>
        <button className=" md:ml-10 font-semibold bg-primaryColor p-4 px-8 text-backgroundColor rounded-lg mt-8">
          Some Text
        </button>
      </div>

      <div class="hidden md:flex col-span-2 text-center md:text-left mt-6 md:mt-0 text-[3.5rem] md:text-[8.5rem] font-extrabold leading-tight">
        Start Making Money With NFT's
      </div>
      {/* <div class="row-span-2 col-span-2">03</div> */}
    </div>
  );
};

export default HeroComp;
