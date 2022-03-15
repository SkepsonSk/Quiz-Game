import { api, LightningElement, track, wire } from 'lwc';

import getQuestions from '@salesforce/apex/QuizPickerController.getQuestions';
import finishQuiz from '@salesforce/apex/QuizPickerController.finishQuiz';

export default class QuizPlayer extends LightningElement {

    @api recordId;

    @track questions;
    @track currentQuestionIndex = 0;

    @wire(getQuestions, {quizId: '$recordId'})
    questionsData({error, data}) {

        if (error) {
            alert(JSON.stringify(error));
            //TODO handle the error.
        }
        else if (data){
            const dataJSON = JSON.stringify(data);
            this.questions = JSON.parse(dataJSON);
        }

    }

    getAnswer(questionId, answerId) {
        return this.questions
            .filter( q => q.Id === questionId )[0]
            .Answers__r.filter( a => a.Id === answerId);
    }

    get getQuestionOrder() {
        return this.currentQuestionIndex+1;
    }

    get currentQuestion() {
        if (this.questions != null) {
            return this.questions[this.currentQuestionIndex];
        }
        return null;
    }

    nextQuestion() {
        this.currentQuestionIndex++;
    }

    prevQuestion() {
        this.currentQuestionIndex--;
    }

    get isLast() {
        return this.currentQuestionIndex == this.questions.length - 1;
    }

    get isFirst() {
        return this.currentQuestionIndex == 0;
    }

    handleAnswerSelected(event) {
        const questionId = event.detail.questionId;
        const answerId = event.detail.answerId;
        const response = event.detail.response;

        const answer = this.getAnswer(questionId, answerId)[0];
        answer.response = response;
    }

    finishQuiz() {
        const answers = this.collectAnswers();

        finishQuiz({questionResponses: answers, quizId: this.recordId})
            .then( quizResult => {
                alert(JSON.stringify(quizResult));
            } ) 
            .catch( error => {
                alert(JSON.stringify(error));
            })
    }

    collectAnswers() {
        const answers = [];

        this.questions.forEach( question => {
            question.Answers__r.forEach( answer => {
                answers.push({
                    answerId: answer.Id,
                    questionId: answer.Question__c,
                    response: answer.response != null ? answer.response : false
                });
            });
        });

        return answers;
    }
}