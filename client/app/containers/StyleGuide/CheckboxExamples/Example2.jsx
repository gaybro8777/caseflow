import React from 'react';

// components
import Checkbox from '../../../components/Checkbox';

export default class Example2 extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      value: true
    };
  }

  onChange = (value) => {
    this.setState({
      value
    });
  }

  render = () => {
    return <Checkbox
      label="Option"
      vertical
      name="checkbox_example_2"
      onChange={this.onChange}
      value={this.state.value}
    />;
  }
}
