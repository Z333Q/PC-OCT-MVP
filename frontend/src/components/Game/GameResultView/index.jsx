import React, { useEffect, useState } from 'react';
import contractService from '../../../services/contractService';
import './styles.css';

const GameResultView = () => {
  const [results, setResults] = useState([]);

  useEffect(() => {
    const fetchResults = async () => {
      const gameResults = await contractService.getGameResults();
      setResults(gameResults);
    };
    fetchResults();
  }, []);

  return (
    <div className="game-result-view">
      <h2>Game Results</h2>
      <ul>
        {results.map((result, index) => (
          <li key={index}>{result}</li>
        ))}
      </ul>
    </div>
  );
};

export default GameResultView;
