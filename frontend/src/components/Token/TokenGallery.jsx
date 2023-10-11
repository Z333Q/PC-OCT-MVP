import React from 'react';
import './TokenGallery.css';  // Importing styles for this component

const CITY_TOKENS = [
    { name: "Anaheim", image: "anaheim.png" },
    { name: "Arizona", image: "arizona.png" },
    { name: "Boston", image: "boston.png" },
    { name: "Buffalo", image: "buffalo.png" },
    { name: "Calgary", image: "calgary.png" },
    { name: "Carolina", image: "carolina.png" },
    { name: "Chicago", image: "chicago.png" },
    { name: "Colorado", image: "colorado.png" },
    { name: "Columbus", image: "columbus.png" },
    { name: "Dallas", image: "dallas.png" },
    { name: "Detroit", image: "detroit.png" },
    { name: "Edmonton", image: "edmonton.png" },
    { name: "Florida", image: "florida.png" },
    { name: "Los Angeles", image: "los-angeles.png" },
    { name: "Minnesota", image: "minnesota.png" },
    { name: "Montreal", image: "montreal.png" },
    { name: "Nashville", image: "nashville.png" },
    { name: "New Jersey", image: "new-jersey.png" },
    { name: "New Island", image: "new-island.png" },
    { name: "New York", image: "new-york.png" },
    { name: "Ottawa", image: "ottawa.png" },
    { name: "Philadelphia", image: "philadelphia.png" },
    { name: "Pittsburgh", image: "pittsburgh.png" },
    { name: "San Jose", image: "san-jose.png" },
      { name: "Seattle", image: "seattle.png" },
    { name: "St. Louis", image: "st-louis.png" },
    { name: "Tampa Bay", image: "tampa-bay.png" },
    { name: "Toronto", image: "toronto.png" },
    { name: "Vancouver", image: "vancouver.png" },
    { name: "Vegas", image: "vegas.png" },
    { name: "Washington", image: "washington.png" },
    { name: "Winnipeg", image: "winnipeg.png" },
  ];

const TokenGallery = () => {
  return (
    <div className="token-gallery">
      {CITY_TOKENS.map((token, index) => (
        <div key={index} className="token-card">
          <img src={`/images/${token.image}`} alt={token.name} />
          <div className="token-name">{token.name}</div>
        </div>
      ))}
    </div>
  );
};

export default TokenGallery;
