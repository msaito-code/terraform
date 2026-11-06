variable "usernames" {
    type = list(string)
    default = ["Reader", "Contributor", "Owner"]
}

variable "permissions" {
    type = map(string)
    default = {
        Owner = "anything"
        Contributor = "almost anything, but can't alter permissions"
        Reader = "only read resource metadata"
    }
}