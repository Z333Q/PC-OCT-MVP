
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

  // Function to convert time to EST
  const convertToEST = (gameTimeInUTC) => {
    const gameTime = new Date(gameTimeInUTC);
    return gameTime.toLocaleString('en-US', { timeZone: 'America/New_York' });
  };

  return (
    <div className="game-result-view">
      <h1>Game Results</h1>
      <table>
        <thead>
          <tr>
            <th>Date</th>
            <th>Home Team</th>
            <th>Away Team</th>
            <th>Home Score</th>
            <th>Away Score</th>
            <th>Time (EST)</th>
          </tr>
        </thead>
        <tbody>
          {results.map((result, index) => (
            <tr key={index}>
              <td>{result.date}</td>
              <td>{result.homeTeam}</td>
              <td>{result.awayTeam}</td>
              <td>{result.homeScore}</td>
              <td>{result.awayScore}</td>
              <td>{convertToEST(result.gameTime)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default GameResultView;
