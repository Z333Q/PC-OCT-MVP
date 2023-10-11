// src/routes.js

import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import Admin from './components/Admin/Admin';
import ProtectedRoute from './components/ProtectedRoute';
// ... other imports

const Routes = () => (
  <Router>
    <Switch>
      {/* ... other routes */}
      <Route path="/admin" render={props => <ProtectedRoute {...props} component={Admin} />} />
    </Switch>
  </Router>
);

export default Routes;

