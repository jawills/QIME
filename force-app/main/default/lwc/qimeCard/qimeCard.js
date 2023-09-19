import { LightningElement, api } from 'lwc';

export default class QimeCard extends LightningElement {
    @api title
    @api body
    @api link
    @api loading
    handleClick(){
        window.open(this.link)
    }
}