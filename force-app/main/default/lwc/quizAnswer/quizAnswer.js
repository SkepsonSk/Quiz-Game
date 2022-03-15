import { api, LightningElement } from 'lwc';

export default class QuizAnswer extends LightningElement {

    @api answer;

    get isSelected() {
        console.log(this.answer.response);
        return this.answer.response === true;
    }

    selectAnswer(event) {
        const answerSelectedEvent = new CustomEvent('answerselected', {
            detail: { 
                answerId: this.answer.Id,
                questionId: this.answer.Question__c,
                response: event.detail.checked 
            }
        });

        this.dispatchEvent(answerSelectedEvent);
    }
}