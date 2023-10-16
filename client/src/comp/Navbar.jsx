import React, { useState } from "react";
import { BiMenuAltRight } from "react-icons/bi";
import { Link } from "react-router-dom";

const Navbar = () => {
  const [isMenu, setIsMenu] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(true);

  const handleMenu = () => {
    setIsMenu(!isMenu);
  };

  return (
    <div>
      {/* desk */}
      <div className=" hidden md:flex md:items-center md:justify-center">
        <ul className=" flex gap-14 bg-cardBg p-4 md:mt-8 mt-4 rounded-full px-10">
          <Link to="/">
            <li className=" cursor-pointer">Home</li>
          </Link>
          <Link to="/takeLoan">
            <li className=" cursor-pointer">Take Loan</li>
          </Link>
          {isLoggedIn ? (
            <div className="flex gap-14">
              <Link to="/repayLoan">
                <li className=" cursor-pointer">Repay Loan</li>
              </Link>
              <li className=" cursor-pointer text-red-200">Sign Out</li>
            </div>
          ) : (
            <li className=" cursor-pointer">Sign In</li>
          )}
        </ul>
      </div>

      {/* mobile */}
      <div
        className=" flex md:hidden justify-end mt-6 text-3xl"
        onClick={handleMenu}
      >
        <BiMenuAltRight />
        {isMenu && (
          <div className=" absolute top-14 text-base bg-cardBg py-2 px-4 rounded-lg z-50">
            <ul>
              <Link to="/">
                <li className=" mt-1">Home</li>
              </Link>
              <Link to="/takeLoan">
                <li className=" mt-1">Take Loan</li>
              </Link>
              {isLoggedIn ? (
                <div>
                  <Link to="/repayLoan">
                    <li className=" mt-1">Repay Loan</li>
                  </Link>
                  <li className="mt-1 text-red-200">Sign Out</li>
                </div>
              ) : (
                <li className="mt-1">Sign In</li>
              )}{" "}
            </ul>
          </div>
        )}
      </div>
    </div>
  );
};

export default Navbar;
