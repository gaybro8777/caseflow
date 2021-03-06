import React from 'react';
import _ from 'lodash';
import StyleGuideComponentTitle from '../../components/StyleGuideComponentTitle';

// components
import Table from '../../components/Table';

export default class StyleGuideTables extends React.PureComponent {
  render = () => {
  // List of objects which will be used to create each row
    const rowObjects = [
      { name: 'Shane',
        favoriteAnimal: 'Hamster',
        likesSports: true },
      { name: 'Kavi',
        favoriteAnimal: 'Koala Bear',
        likesSports: false },
      { name: 'Gina',
        favoriteAnimal: 'Otter',
        likesSports: false }
    ];

    const columns = [
      {
        header: 'Name',
        valueName: 'name',
        footer: 'Totals'
      },
      {
        header: 'Favorite Animal',
        align: 'center',
        valueName: 'favoriteAnimal',
        footer: '3'
      },
      {
        header: 'Likes sports?',
        align: 'center',
        valueFunction: (person) => {
          return person.likesSports ? 'Yes' : 'No';
        },
        footer: '1'
      }
    ];

    const rowClassNames = (rowObject) => {
      return rowObject.likesSports ? 'cf-success' : '';
    };

    const columnsWithAction = _.concat(columns, [
      {
        header: 'Poke',
        align: 'right',
        valueFunction: (person, rowNumber) => {
          return <a href={`#poke-${rowNumber}`}>Poke {person.name} »</a>;
        }
      }
    ]);

    const summary = 'Example styleguide table';

    return <div className="cf-sg-tables-section">
      <StyleGuideComponentTitle
        title="Tables"
        id="tables"
        link="StyleGuideTables.jsx"
      />
      <p>
      We use tables to display information across Caseflow.
      Most frequently they are used in users’ Queues but we
      sometimes use them to help users accomplish a specific task. For aesthetic
      purposes, tables in Caseflow are borderless.
      </p>
      <p>
    Table headings should be bold and with a white background.
      </p>
      <p>
      Often tables will contain an primary action a user can
      take on the table item. These actions should
      always be placed in the right most column of the table and
      should be right aligned with the edge of the table.
      </p>
      <Table columns={columns} rowObjects={rowObjects} rowClassNames={rowClassNames} summary={summary}
        slowReRendersAreOk />

      <h3 id="queues">Queues</h3>
      <p>
      Tables are most frequently used in users' Queues or
      a list of work items for a user to take action on.
      Queues are shown in the standard App Canvas as
      tables. A distinct feature of queue tables is the
      right-aligned actionable link, such as
      "Assign >>," located on the far right column.
      </p>
      <Table columns={columnsWithAction} rowObjects={rowObjects} summary={summary} slowReRendersAreOk />
    </div>;
  }
}

