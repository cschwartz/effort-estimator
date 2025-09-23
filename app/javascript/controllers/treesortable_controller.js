//import Sortable from "@stimulus-components/sortable"
import Sortable from "sortablejs"
import { Controller } from "@hotwired/stimulus"
import { patch } from "@rails/request.js"

export default class StimulusSortable extends Controller {
    static values = {
        resourceName: String,
        groupName: String,
        paramName: {
            type: String,
            default: "position",
        },
        parentParamName: {
            type: String,
            default: "parent_id",
        },
        responseKind: {
            type: String,
            default: "html",
        },
        animation: Number,
        handle: String,
    }

    initialize() {
        this.onUpdate = this.onUpdate.bind(this)
    }

    connect() {
        this.sortables = [];
        document.querySelectorAll("ul").forEach((el) => {
            this.sortables.push(new Sortable(el, {
                ...this.options,
            }));
        });
    }

    disconnect() {
        this.sortables.forEach((sortable) => {
            sortable.destroy()
        })
        this.sortables = [];
    }

    async onUpdate(event) {
        const { item, to, newIndex } = event
        if (!item.dataset.treesortableUpdateUrl) return

        const data = new FormData()

        const newParent = to.closest('.effort-node')
        data.append(this.parentParamName, newParent?.dataset?.treesortableId ?? '')
        data.append(this.positionParamName, newIndex)

        return await patch(item.dataset.treesortableUpdateUrl, { body: data, responseKind: this.responseKindValue })
            .then(response => response.text)
            .then(html => {
                Turbo.renderStreamMessage(html)
            })
    }

    get options() {
        return {
            animation: this.animationValue || this.defaultOptions.animation,
            handle: this.handleValue || this.defaultOptions.handle,
            responseKind: this.responseKindValue || this.defaultOptions.responseKind,
            group: this.groupValue || this.defaultOptions.group,
            onEnd: this.onUpdate
        }
    }

    get defaultOptions() {
        return {
            animation: 150,
            handle: undefined,
            responseKind: "html",
            group: "group"
        }
    }

    get positionParamName() {
        return this.resourceNameValue ? `${this.resourceNameValue}[${this.paramNameValue}]` : this.paramNameValue
    }

    get parentParamName() {
        return this.resourceNameValue ? `${this.resourceNameValue}[${this.parentParamNameValue}]` : this.parentParamNameValue
    }
}