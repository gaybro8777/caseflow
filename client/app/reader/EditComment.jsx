import React from 'react';
import PropTypes from 'prop-types';

import Button from '../components/Button';
import DateSelector from '../components/DateSelector';

// A rounded rectangle with a text box for adding
// or editing an existing comment.
export default class EditComment extends React.Component {

  constructor(props) {
    super(props);

    this.shouldAutosave = true;
  }

  isSaveDisabled = () => (
    this.props.disableOnEmpty && this.isStringEmpty(this.props.comment.comment)
  )

  handleAutoSave = () => {
    // only autosave when a comment exists
    if (this.shouldAutosave && !this.isSaveDisabled()) {
      this.onSaveCommentEdit();
    }
  }

  keyListener = (event) => {
    if (event.altKey && event.key === 'Enter' && this.props.comment.comment && this.props.comment.comment.trim()) {
      this.onSaveCommentEdit();
      event.stopPropagation();
    }
  }

  componentDidMount = () => {
    let commentBox = document.getElementById(this.props.id);

    commentBox.focus();

    // ensure we autosave if we ever exit
    window.addEventListener('beforeunload', this.handleAutoSave);
  }

  componentWillUnmount() {
    window.removeEventListener('beforeunload', this.handleAutoSave);
    this.handleAutoSave();
  }

  onChange = (event) => this.props.onChange(event.target.value, this.props.comment.uuid);

  onChangeDate = (relevantDate) => this.props.onChangeDate(relevantDate, this.props.comment.uuid);

  onCancelCommentEdit = () => {
    this.shouldAutosave = false;
    this.props.onCancelCommentEdit(this.props.comment.uuid);
  }

  onSaveCommentEdit = () => {
    this.shouldAutosave = false;
    this.props.onSaveCommentEdit(this.props.comment);
  }

  isStringEmpty = (str = '') => !str.trim();

  render() {
    return <div>
      <DateSelector
        name="Relevant Date"
        onChange={this.onChangeDate}
        value={this.props.comment.relevant_date}
        type="date"
        strongLabel
      />
      <textarea
        className="comment-container comment-textarea"
        name="Edit Comment"
        aria-label="Edit Comment"
        onKeyDown={this.keyListener}
        id={this.props.id}
        onChange={this.onChange}
        value={this.props.comment.comment}
      />
      <div className="comment-save-button-container">
        <span className="cf-right-side">
          <Button
            name="cancel"
            classNames={['cf-btn-link']}
            onClick={this.onCancelCommentEdit}>
              Cancel
          </Button>
          <Button
            disabled={this.isSaveDisabled()}
            name="save"
            onClick={this.onSaveCommentEdit}>
              Save
          </Button>
        </span>
      </div>
    </div>;
  }
}

EditComment.defaultProps = {
  id: 'commentEditBox'
};

EditComment.propTypes = {
  comment: PropTypes.object.isRequired,
  disableOnEmpty: PropTypes.bool,
  id: PropTypes.string,
  onSaveCommentEdit: PropTypes.func,
  onCancelCommentEdit: PropTypes.func
};
