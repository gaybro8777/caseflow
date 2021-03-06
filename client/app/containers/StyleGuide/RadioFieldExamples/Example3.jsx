import React from 'react';

// components
import RadioField from '../../../components/RadioField';

export default class Example3 extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      value: '2'
    };
  }

  onChange = (value) => {
    this.setState({
      value
    });
  }

  render = () => {
    let options = [
      { displayText: 'One',
        value: '1' },
      { displayText: 'Two',
        value: '2' }
    ];

    return <RadioField
      label={<h4>Horizontal Radio Button Forced Into Vertical Layout</h4>}
      name="radio_example_3"
      options={options}
      vertical
      value={this.state.value}
      onChange={this.onChange}
    />;
  }
}
