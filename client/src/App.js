import React from "react";
import Navbar from "./comp/Navbar";
import { Route, Routes } from "react-router-dom";
import Homepage from "./pages/Homepage";
import TakeLoan from "./comp/TakeLoan";
import RepayLoan from "./comp/RepayLoan";

const App = () => {
  return (
    <div className=" px-8 md:px-16 ">
      <Navbar />
      <Routes>
        <Route path="/*" element={<Homepage />} />
        <Route path="/takeLoan" element={<TakeLoan />} />
        <Route path="/repayLoan" element={<RepayLoan />} />
      </Routes>
    </div>
  );
};

export default App;
