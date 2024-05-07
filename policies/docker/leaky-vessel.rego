# title: "TEST"
# description: "TEST"
# scope: package
# custom:
#   id: ID001 
#   avd_id: AVD-DOCK-0001
#   severity: HIGH 
#   short_code: test
#   recommended_action: "test"
#   input:
#     selector:
#     - type: dockerfile

package user.dockerfile.ID001 

deny[msg] {
    input.Stages[i].Commands[l].Cmd == "run"
    msg := "test"
}