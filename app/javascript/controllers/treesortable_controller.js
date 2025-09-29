//import Sortable from "@stimulus-components/sortable"
import Sortable from "sortablejs"
import { Controller } from "@hotwired/stimulus"
import { patch } from "@rails/request.js"

export default class StimulusSortable extends Controller {
    static values = {
        resourceName: String,
        groupName: {
            type: String,
            default: "group",
        },
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
        animation: {
            type: Number,
            default: 150,
        },
        handle: String,
        ghostClass: {
            type: String,
            default: "ghost",
        },
        emptyInsertThreshold: {
            type: Number,
            default: 5,
        },
        swapThreshold: {
            type: Number,
            default: 0.65,
        },
        fallbackOnBody: {
            type: Boolean,
            default: true,
        },
    }

    initialize() {
        this.onEnd = this.onEnd.bind(this)
    }

    connect() {
        this.sortables = [];
        this.sortables.push(new Sortable(this.element, {
                ...this.options,
            }));
        this.element.querySelectorAll(".effort-subtree").forEach((el) => {
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

    async onEnd(event) {
        const { item, to, newIndex } = event
        if (!item.dataset.treesortableUpdateUrl) return

        const data = new FormData()

        const newParent = to.closest('.effort-node')
        data.append(this.parentParamName, newParent?.dataset?.treesortableId ?? '')
        data.append(this.positionParamName, newIndex)

        return await patch(item.dataset.treesortableUpdateUrl, { body: data, responseKind: this.responseKindValue })
    }

    get options() {
        return {
            animation: this.animationValue,
            handle: this.handleValue,
            responseKind: this.responseKindValue,
            group: this.groupNameValue,
            fallbackOnBody: this.fallbackOnBodyValue,
            swapThreshold: this.swapThresholdValue,
            emptyInsertThreshold: this.emptyInsertThresholdValue,
            onEnd: this.onEnd,
            ghostClass: this.ghostClassValue
        }
    }


    get positionParamName() {
        return this.resourceNameValue ? `${this.resourceNameValue}[${this.paramNameValue}]` : this.paramNameValue
    }

    get parentParamName() {
        return this.resourceNameValue ? `${this.resourceNameValue}[${this.parentParamNameValue}]` : this.parentParamNameValue
    }
}